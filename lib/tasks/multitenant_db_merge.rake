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
  config_map = -> (x) { x.except('id', 'fund_id', 'config_value').merge('fund_id' => @fund_id, 'config_value' => JSON.parse(x['config_value'])) }
  @config_mappings = easy_mass_insert Config, 'configs', config_map

  # Port clinics
  clinic_map = -> (x) { x.except('id', 'fund_id').merge('fund_id' => @fund_id) }
  @clinic_mappings = easy_mass_insert Clinic, 'clinics', clinic_map

  # Port lines
  line_map = -> (x) { x.except('id', 'fund_id').merge('fund_id' => @fund_id) }
  @line_mappings = easy_mass_insert Line, 'lines', line_map

  # Port users
  user_map = -> (x) { x.except('id', 'fund_id', 'line').merge('fund_id' => @fund_id) }
  @user_mappings = easy_mass_insert User, 'users', user_map

  # Port patients
  patient_map = -> (x) {
    x.except('id', 'fund_id', 'line_id', 'clinic_id', 'pledge_generated_by_id', 'pledge_sent_by_id', 'last_edited_by_id')
     .merge({
       'fund_id' => @fund_id,
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
    x.except('id', 'fund_id', 'line_id', 'clinic_id', 'pledge_generated_by_id', 'pledge_sent_by_id', 'last_edited_by_id')
     .merge({
       'fund_id' => @fund_id,
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
    res = x.except('id', 'can_call_id', 'fund_id')
      .merge({
        'fund_id' => @fund_id,
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
    res = x.except('id', 'can_pledge_id', 'fund_id')
      .merge({
        'fund_id' => @fund_id,
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
    res = x.except('id', 'can_fulfill_id', 'fund_id')
      .merge({
        'fund_id' => @fund_id,
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
    res = x.except('id', 'can_support_id', 'fund_id')
      .merge({
        'fund_id' => @fund_id,
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
    res = x.except('id', 'fund_id', 'patient_id')
           .merge({
             'fund_id' => @fund_id,
             'patient_id' => @patient_mappings[x['patient_id']]
           })
    res['patient_id'].nil? ? nil : res
  }
  @note_mappings = easy_mass_insert Note, 'notes', note_map, false

  # Port call list entries
  cle_map = -> (x) {
    res = x.except('id', 'fund_id', 'line_id', 'patient_id', 'user_id')
           .merge({
             'fund_id' => @fund_id,
             'line_id' => @line_mappings[x['line_id']],
             'patient_id' => @patient_mappings[x['patient_id']],
             'user_id' => @user_mappings[x['user_id']]
           })
    res['patient_id'].nil? ? nil : res
  }
  @call_list_entry_mappings = easy_mass_insert CallListEntry, 'call_list_entries', cle_map, false

  # Port events
  event_map = -> (x) {
    res = x.except('id', 'fund_id', 'line_id', 'patient_id')
           .merge({
             'fund_id' => @fund_id,
             'line_id' => @line_mappings[x['line_id']],
             'patient_id' => @patient_mappings[x['patient_id']],
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
    'User' => @user_mappings
  }

  def transform_obj(obj, item_type, value_will_be_array)
    obj.each_pair do |k, v|
      obj['id'] = @item_type_mappings[item_type][v] if k == 'id'
      if @fkey_mappings.keys.include? k
        if k.start_with? 'can'
          raise 'something about properly picking can ype here'
          raise 'may want to just query for these directly tbh'
        else
          obj[key] = value_will_be_array ? v.map { |x| @fkey_mappings[k][x] } : @fkey_mappings[k][v]
        end
      end
    end
    obj
  end

  # Transfer versions, porting keys along the way
  version_map = -> (x) {
    x.exclude('id', 'item_id', 'fund_id', 'object', 'object_changes', 'whodunnit')
     .merge({
       'item_id' => @item_type_mappings[v['item_type'][v['item_id']]],
       'whodunnit' => @user_mappings[v['whodunnit'].to_i],
       'object_changes' => transform_obj(JSON.parse(v['object_changes']), v['item_type'], true),
       'object' => transform_obj(JSON.parse(v['object']), v['item_type'], false)
     })
  }
  # puts "#{Time.now} porting versions"
  # offset = 0
  # total = 0
  # connect_to_migration_db
  # versions = ActiveRecord::Base.connection.execute('select * from versions limit 250')
  # while versions.ntuples.to_i > 0
  #   connect_to_target_db
  #   versions.each do |v|
  #     PaperTrailVersion.create! v.exclude('id', 'item_id', 'fund_id', 'object', 'object_changes', 'whodunnit')
  #                                .merge({
  #                                  'item_id' => @item_type_mappings[v['item_type'][v['item_id']]],
  #                                  'whodunnit' => @user_mappings[v['whodunnit'].to_i],
  #                                  'object_changes' => transform_obj(JSON.parse(v['object_changes']), v['item_type'], true),
  #                                  'object' => transform_obj(JSON.parse(v['object']), v['item_type'], false)
  #                                })
  #   end

  #   # Do another batch
  #   offset = offset + 250
  #   puts "#{Time.now} Another batch of 250 versions"
  #   connect_to_migration_db
  #   versions = ActiveRecord::Base.connection.execute("select * from versions limit 250 offset #{offset}")
  # end
  # puts "#{Time.now} Ported #{PaperTrailVersion.count} patients and #{total} were in original db"
  # raise "COUNT MISMATCH ERROR" unless PaperTrailVersion.count == total

  puts "#{Time.zone.now} Completed"
end
