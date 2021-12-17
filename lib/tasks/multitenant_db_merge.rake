desc 'Merge an ext daria db into main db'
task multitenant_db_merge: :environment do
  raise 'SET MIGRATION_FUND_ID ENV VAR' if not ENV['MIGRATION_FUND_ID']
  raise 'SET MIGRATION_DB_URL ENV VAR' if not ENV['MIGRATION_DB_URL']

  # Make absolutely sure the new fund has been created!
  fund = Fund.find ENV['MIGRATION_FUND_ID']
  @fund_id = fund.id

  # Scope funds and turn off papertrail
  ActsAsTenant.current_tenant = fund
  PaperTrail.enabled = false # We're porting these over more directly and don't need extra versions

  # Database we're migrating things into
  def connect_to_target_db
    ActiveRecord::Base.establish_connection(Rails.env.to_sym)
  end

  # Database we're migrating things out of
  def connect_to_migration_db
    ActiveRecord::Base.establish_connection(
      adapter: 'postgresql',
      encoding: 'unicode',
      pool: 10,
      url: ENV['MIGRATION_DB_URL']
    )
    ActiveRecord::Base.connection.execute(
      "set session characteristics as transaction read only;"
    )
  end

  puts "Migrating into fund_id #{@fund_id}..."

  if Patient.count() > 0
    raise 'Possibly already ported? patients belonging to that fund_id are found'
  end

  # Store the mappings between an old id and new id, and update them as we port the goods
  @config_mappings = {}
  @clinic_mappings = {}
  @line_mappings = {}
  @user_mappings = {}
  @call_mappings = {}
  @external_pledge_mappings = {}
  @fulfillment_mappings = {}
  @practical_support_mappings = {}
  @note_mappings = {}
  @patient_mappings = {}
  @archived_patient_mappings = {}
  @call_list_entry_mappings = {}
  @event_mappings = {}

  def easy_mass_insert(model, tbl, map_func, check_counts = true)
    puts "#{Time.now} Porting #{model.to_s}"
    connect_to_migration_db
    obj_for_migrate = ActiveRecord::Base.connection.execute("select * from #{tbl} order by id asc")
    connect_to_target_db
    clean_rows = obj_for_migrate.map { |x| map_func.call x }
    result = model.insert_all clean_rows.reject(&:nil?)

    # QA
    puts "#{Time.now} Ported #{model.count} #{model} and #{obj_for_migrate.ntuples} were in original db"
    raise "COUNT MISMATCH ERROR" unless model.count == obj_for_migrate.ntuples if check_counts

    # Map results to new ids
    id_mapping = {}
    result.rows.each_with_index do |x, i|
      id_mapping[obj_for_migrate[i]['id'].to_i] = x[0]
    end

    # Spot check
    puts "Spot check:"
    puts "Raw row: #{obj_for_migrate.first}"
    puts "Clean row: #{clean_rows[0]}"
    puts "Inserted record: #{model.find(id_mapping[obj_for_migrate.first['id']]).attributes}\n\n"

    id_mapping
  end

  # Port configs
  config_map = -> (x) {
    x.except('id', 'fund_id', 'config_value', 'created_at', 'updated_at')
     .merge({
       'fund_id' => @fund_id,
       'created_at' => x['created_at'].asctime.in_time_zone("America/New_York"),
       'updated_at' => x['updated_at'].asctime.in_time_zone("America/New_York"),
       'config_value' => JSON.parse(x['config_value'])
     })
  }
  @config_mappings = easy_mass_insert Config, 'configs', config_map

  # Port clinics
  clinic_map = -> (x) {
    x.except('id', 'fund_id', 'created_at', 'updated_at')
     .merge({
       'fund_id' => @fund_id,
       'created_at' => x['created_at'].asctime.in_time_zone("America/New_York"),
       'updated_at' => x['updated_at'].asctime.in_time_zone("America/New_York")
     })
  }
  @clinic_mappings = easy_mass_insert Clinic, 'clinics', clinic_map

  # Port lines
  line_map = -> (x) {
    x.except('id', 'fund_id', 'created_at', 'updated_at')
     .merge({
       'fund_id' => @fund_id,
       'created_at' => x['created_at'].asctime.in_time_zone("America/New_York"),
       'updated_at' => x['updated_at'].asctime.in_time_zone("America/New_York")
     })
  }
  @line_mappings = easy_mass_insert Line, 'lines', line_map

  # Port users
  user_map = -> (x) {
    x.except('id', 'fund_id', 'line', 'created_at', 'updated_at')
     .merge({
       'fund_id' => @fund_id,
       'created_at' => x['created_at'].asctime.in_time_zone("America/New_York"),
       'updated_at' => x['updated_at'].asctime.in_time_zone("America/New_York")
     })
  }
  @user_mappings = easy_mass_insert User, 'users', user_map

  # Port patients
  patient_map = -> (x) {
    x.except('id', 'fund_id', 'created_at', 'updated_at', 'line_id', 'clinic_id', 'pledge_generated_by_id', 'pledge_sent_by_id', 'last_edited_by_id')
     .merge({
       'fund_id' => @fund_id,
       'created_at' => x['created_at'].asctime.in_time_zone("America/New_York"),
       'updated_at' => x['updated_at'].asctime.in_time_zone("America/New_York"),
       'clinic_id' => @clinic_mappings[x['clinic_id']],
       'line_id' => @line_mappings[x['line_id']],
       'pledge_generated_by_id' => @user_mappings[x['pledge_generated_by_id']],
       'pledge_sent_by_id' => @user_mappings[x['pledge_sent_by_id']],
       'last_edited_by_id' => @user_mappings[x['last_edited_by_id']]
     })
  }
  @patient_mappings = easy_mass_insert Patient, 'patients', patient_map

  # Port archived patients
  archived_patient_map = -> (x) {
    x.except('id', 'fund_id', 'created_at', 'updated_at', 'line_id', 'clinic_id', 'pledge_generated_by_id', 'pledge_sent_by_id', 'last_edited_by_id')
     .merge({
       'fund_id' => @fund_id,
       'created_at' => x['created_at'].asctime.in_time_zone("America/New_York"),
       'updated_at' => x['updated_at'].asctime.in_time_zone("America/New_York"),
       'clinic_id' => @clinic_mappings[x['clinic_id']],
       'line_id' => @line_mappings[x['line_id']],
       'pledge_generated_by_id' => @user_mappings[x['pledge_generated_by_id']],
       'pledge_sent_by_id' => @user_mappings[x['pledge_sent_by_id']],
     })
  }
  @archived_patient_mappings = easy_mass_insert ArchivedPatient, 'archived_patients', archived_patient_map

  # Note about subobjects: there are some abandoned records (e.g. from patients who were deleted)
  # so we don't count check on these
  # Port calls
  call_map = -> (x) {
    res = x.except('id', 'can_call_id', 'fund_id', 'created_at', 'updated_at')
      .merge({
        'fund_id' => @fund_id,
        'created_at' => x['created_at'].asctime.in_time_zone("America/New_York"),
        'updated_at' => x['updated_at'].asctime.in_time_zone("America/New_York"),
        'can_call_id' => if x['can_call_type'] == 'Patient'
                           @patient_mappings[x['can_call_id']]
                         elsif x['can_call_type'] == 'ArchivedPatient'
                           @archived_patient_mappings[x['can_call_id']]
                         else
                           raise "unexpected type - row #{x}"
                         end
      })
    res['can_call_id'].nil? ? nil : res
  }
  @call_mappings = easy_mass_insert Call, 'calls', call_map, false

  # Port ext pledges
  ext_pledge_map = -> (x) {
    res = x.except('id', 'created_at', 'updated_at', 'can_pledge_id', 'fund_id')
      .merge({
        'fund_id' => @fund_id,
        'created_at' => x['created_at'].asctime.in_time_zone("America/New_York"),
        'updated_at' => x['updated_at'].asctime.in_time_zone("America/New_York"),
        'can_pledge_id' => if x['can_pledge_type'] == 'Patient'
                           @patient_mappings[x['can_pledge_id']]
                         elsif x['can_pledge_type'] == 'ArchivedPatient'
                           @archived_patient_mappings[x['can_pledge_id']]
                         else
                           raise "unexpected type - row #{x}"
                         end
      })
    res['can_pledge_id'].nil? ? nil : res
  }
  @external_pledge_mappings = easy_mass_insert ExternalPledge, 'external_pledges', ext_pledge_map, false

  # Port fulfillments
  fulfillment_map = -> (x) {
    res = x.except('id', 'created_at', 'updated_at', 'can_fulfill_id', 'fund_id')
      .merge({
        'fund_id' => @fund_id,
        'created_at' => x['created_at'].asctime.in_time_zone("America/New_York"),
        'updated_at' => x['updated_at'].asctime.in_time_zone("America/New_York"),
        'can_fulfill_id' => if x['can_fulfill_type'] == 'Patient'
                              @patient_mappings[x['can_fulfill_id']]
                            elsif x['can_fulfill_type'] == 'ArchivedPatient'
                              @archived_patient_mappings[x['can_fulfill_id']]
                            else
                              raise "unexpected type - row #{x}"
                            end
      })
    res['can_fulfill_id'].nil? ? nil : res
  }
  @fulfillment_mappings = easy_mass_insert Fulfillment, 'fulfillments', fulfillment_map, false

  # Port practical supports
  psup_map = -> (x) {
    res = x.except('id', 'created_at', 'updated_at', 'can_support_id', 'fund_id')
      .merge({
        'fund_id' => @fund_id,
        'created_at' => x['created_at'].asctime.in_time_zone("America/New_York"),
        'updated_at' => x['updated_at'].asctime.in_time_zone("America/New_York"),
        'can_support_id' => if x['can_support_type'] == 'Patient'
                           @patient_mappings[x['can_support_id']]
                         elsif x['can_support_type'] == 'ArchivedPatient'
                           @archived_patient_mappings[x['can_support_id']]
                         else
                           raise "unexpected type - row #{x}"
                         end
      })
    res['can_support_id'].nil? ? nil : res
  }
  @practical_support_mappings = easy_mass_insert PracticalSupport, 'practical_supports', psup_map, false

  # Port notes
  note_map = -> (x) {
    res = x.except('id', 'created_at', 'updated_at', 'fund_id', 'patient_id')
           .merge({
             'fund_id' => @fund_id,
             'created_at' => x['created_at'].asctime.in_time_zone("America/New_York"),
             'updated_at' => x['updated_at'].asctime.in_time_zone("America/New_York"),
             'patient_id' => @patient_mappings[x['patient_id']]
           })
    res['patient_id'].nil? ? nil : res
  }
  @note_mappings = easy_mass_insert Note, 'notes', note_map, false

  # Port call list entries
  cle_map = -> (x) {
    res = x.except('id', 'created_at', 'updated_at', 'fund_id', 'line_id', 'patient_id', 'user_id')
           .merge({
             'fund_id' => @fund_id,
             'created_at' => x['created_at'].asctime.in_time_zone("America/New_York"),
             'updated_at' => x['updated_at'].asctime.in_time_zone("America/New_York"),
             'line_id' => @line_mappings[x['line_id']],
             'patient_id' => @patient_mappings[x['patient_id']],
             'user_id' => @user_mappings[x['user_id']]
           })
    res['patient_id'].nil? ? nil : res
  }
  @call_list_entry_mappings = easy_mass_insert CallListEntry, 'call_list_entries', cle_map, false

  # Port events
  event_map = -> (x) {
    res = x.except('id', 'created_at', 'updated_at', 'fund_id', 'line_id', 'patient_id')
           .merge({
             'fund_id' => @fund_id,
             'created_at' => x['created_at'].asctime.in_time_zone("America/New_York"),
             'updated_at' => x['updated_at'].asctime.in_time_zone("America/New_York"),
             'line_id' => @line_mappings[x['line_id']],
             'patient_id' => @patient_mappings[x['patient_id'].to_i],
           })
    res['patient_id'].nil? ? nil : res
  }
  @event_mappings = easy_mass_insert Event, 'events', event_map, false

  # Versions, maybe a little more complicated...
  @fkey_mappings = {
    'fund_id' => {@fund_id => @fund_id},
    'clinic_id' => @clinic_mappings,
    'pledge_generated_by_id' => @user_mappings,
    'pledge_sent_by_id' => @user_mappings,
    'last_edited_by_id' => @user_mappings,
    'user_id' => @user_mappings,
    'line_id' => @line_mappings,
    'patient_id' => @patient_mappings,
    'can_call_id' => @patient_mappings,
    'can_pledge_id' => @patient_mappings,
    'can_fulfill_id' => @patient_mappings,
    'can_support_id' => @patient_mappings
  }
  @item_type_mappings = {
    'ArchivedPatient' => @archived_patient_mappings,
    'Call' => @call_mappings,
    'CallListEntry' => @call_list_entry_mappings,
    'Clinic' => @clinic_mappings,
    'Config' => @config_mappings,
    'ExternalPledge' => @external_pledge_mappings,
    'Event' => @event_mappings,
    'Fulfillment' => @fulfillment_mappings,
    'Line' => @line_mappings,
    'Note' => @note_mappings,
    'Patient' => @patient_mappings,
    'User' => @user_mappings,
    'PracticalSupport' => @practical_support_mappings,
  }

  def transform_obj(obj, item_type, value_will_be_array)
    obj.each_pair do |k, v|
      obj['id'] = @item_type_mappings[item_type][v] if k == 'id'
      if @fkey_mappings.keys.include? k || (k.start_with?('can_') && k.end_with?('_id'))
        keyset = if k == 'can_call_id'
                   obj['can_call_type'] == 'Patient' ? @patient_mappings : @archived_patient_mappings
                 elsif k == 'can_pledge_id'
                   obj[k] = obj['can_pledge_type'] == 'Patient' ? @patient_mappings : @archived_patient_mappings
                 elsif k == 'can_fulfill_id'
                   obj[k] = obj['can_fulfill_type'] == 'Patient' ? @patient_mappings : @archived_patient_mappings
                 elsif k == 'can_support_id'
                   obj[k] = obj['can_support_type'] == 'Patient' ? @patient_mappings : @archived_patient_mappings
                 else
                   @fkey_mappings[k]
                 end

        obj[k] = value_will_be_array ? v.map { |x| keyset[v] } : keyset[v]
      end
    end
    obj
  end

  # Transfer versions, porting keys along the way
  version_map = -> (x) {
    res = x.except('id', 'created_at', 'item_id', 'fund_id', 'object', 'object_changes', 'whodunnit')
           .merge({
             'item_id' => @item_type_mappings[x['item_type']][x['item_id']],
             'created_at' => x['created_at'].asctime.in_time_zone("America/New_York"),
             'whodunnit' => x['whodunnit'].nil? ? nil : @user_mappings[x['whodunnit'].to_i],
             'object_changes' => x['object_changes'].nil? ? nil : transform_obj(JSON.parse(x['object_changes']), x['item_type'], true),
             'object' => x['object'].nil? ? nil : transform_obj(JSON.parse(x['object']), x['item_type'], false)
           })
    res['item_id'].nil? ? nil : res
  }
  @version_mappings = easy_mass_insert PaperTrailVersion, 'versions', version_map, false

  puts "#{Time.zone.now} Completed"
end
