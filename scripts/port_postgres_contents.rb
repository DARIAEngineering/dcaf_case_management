# Make absolutely sure the new fund has been created!
@fund_id = 5

if Patient.where(fund_id: fund_id).count() > 0
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

# Port configs
puts 'Porting configs'
ActiveRecord::Base.connection.execute('select * from configs_transfer').each do |x|
  ported = Config.create! x.except('id', 'fund_id').merge({'fund_id' => @fund_id})
  @config_mappings[x['id'].to_i] = ported.id
end

# Port clinics, and store the mappings between old and new
puts 'Porting clinics'
ActiveRecord::Base.connection.execute('select * from clinics_transfer').each do |x|
  ported = Clinic.create! x.except('id', 'fund_id').merge({'fund_id' => @fund_id})
  @clinic_mappings[x['id'].to_i] = ported.id
end

# Port lines, and store the mappings between old and new
puts 'Porting lines'
ActiveRecord::Base.connection.execute('select * from lines_transfer').each do |x|
  ported = Line.create! x.except('id', 'fund_id').merge({'fund_id' => @fund_id})
  @line_mappings[x['id'].to_i] = ported.id
end

# Port users, and store the mappings between old and new
puts 'Porting users'
ActiveRecord::Base.connection.execute('select * from users_transfer').each do |x|
  ported = User.create! x.except('id', 'fund_id').merge({'fund_id' => @fund_id})
  @user_mappings[x['id'].to_i] = ported.id
end

# Def a helper function to correct FKs
def port_patient_subobjs(type, old_id, new_id)
  # Calls
  ActiveRecord::Base.connection.execute("select * from calls_transfer where can_call_type = '#{type}' and can_call_id = #{old_id}").each do |c|
    ported = Call.create! c.except('id', 'can_call_id', 'fund_id').merge({'fund_id' => @fund_id, 'can_call_id' => new_id})
    @call_mappings[c['id'].to_i] = ported.id
  end

  # External Pledge
  ActiveRecord::Base.connection.execute("select * from external_pledges_transfer where can_pledge_type = '#{type}' and can_pledge_id = #{old_id}").each do |e|
    ported = ExternalPledge.create! e.except('id', 'can_pledge_id', 'fund_id').merge({'fund_id' => @fund_id, 'can_pledge_id' => new_id})
    @external_pledge_mappings[e['id'].to_i] = ported.id
  end

  # Fulfillment
  ActiveRecord::Base.connection.execute("select * from calls_transfer where can_fulfill_type = '#{type}' and can_fulfill_id = #{old_id}").each do |f|
    ported = Fulfillment.create! f.except('id', 'can_fulfill_id', 'fund_id').merge({'fund_id' => @fund_id, 'can_fulfill_id' => new_id})
    @fulfillment_mappings[f['id'].to_i] = ported.id
  end

  # Practical Support
  ActiveRecord::Base.connection.execute("select * from practical_supports_transfer where can_support_type = '#{type}' and can_support_id = #{old_id}").each do |ps|
    ported = PracticalSupport.create! ps.except('id', 'fund_id', 'can_support_id').merge({'fund_id' => @fund_id, 'can_support_id' => new_id})
    @practical_support_mappings[f['id'].to_i] = ported.id
  end

  # Note if patient
  ActiveRecord::Base.connection.execute("select * from notes_transfer where patient_id = #{old_id}").each do |n|
    ported = Note.create! n.except('id', 'fund_id', 'patient_id').merge({'fund_id' => @fund_id, 'patient_id' => new_id})
    @note_mappings[n['id'].to_i] = ported.id
  end if type == 'Patient'
end

# Here we go. Port patients and their subobjects in increments of 500
puts "Porting patients and subobjects"
offset = 0
patients = ActiveRecord::Base.connection.execute("select * from patients_transfer limit 500 offset #{offset}")
while patients.length > 0
  patients.each do |x|
    ported_patient = Patient.create! x.except('id', 'fund_id', 'line_id', 'clinic_id', 'pledge_generated_by_id', 'pledge_sent_by_id', 'last_edited_by_id')
                                      .merge({
                                        'fund_id' => @fund_id,
                                        'clinic_id' => @clinic_mappings[x['clinic_id']],
                                        'line_id' => @line_mappings[x['line_id']],
                                        'pledge_generated_by_id' => @user_mappings[x['pledge_generated_by_id']],
                                        'pledge_sent_by_id' => @user_mappings[x['pledge_sent_by_id']],
                                        'last_edited_by_id' => @user_mappings[x['last_edited_by_id']]
                                      })
    @patient_mappings[x['id'].to_i] = ported_patient.id

    port_patient_subobjs('Patient', x['id'], ported_patient.id)
  end

  # Do another batch
  offset = offset + 500
  puts "#{Time.now} Another batch of 500 pts"
  patients = ActiveRecord::Base.connection.execute("select * from patients_transfer limit 500 offset #{offset}")
end


# Here we go part 2. Port archived and their subobjects in increments of 500
puts "Porting archivedpatients and subobjects"
offset = 0
archived_patients = ActiveRecord::Base.connection.execute("select * from archived_patients_transfer limit 500 offset #{offset}")
while archived_patients.length > 0
  archived_patients.each do |x|
    ported_patient = ArchivedPatient.create! x.except('id', 'fund_id', 'line_id', 'clinic_id', 'pledge_generated_by_id', 'pledge_sent_by_id', 'last_edited_by_id')
                                      .merge({
                                        'fund_id' => @fund_id,
                                        'clinic_id' => @clinic_mappings[x['clinic_id']],
                                        'line_id' => @line_mappings[x['line_id']],
                                        'pledge_generated_by_id' => @user_mappings[x['pledge_generated_by_id']],
                                        'pledge_sent_by_id' => @user_mappings[x['pledge_sent_by_id']],
                                        'last_edited_by_id' => @user_mappings[x['last_edited_by_id']]
                                      })
    @archived_patient_mappings[x['id'].to_i] = ported_patient.id

    port_patient_subobjs('ArchivedPatient', x['id'], ported_patient.id)
  end

  # Do another batch
  offset = offset + 500
  puts "#{Time.now} Another batch of 500 pts"
  archived_patients = ActiveRecord::Base.connection.execute("select * from archived_patients_transfer limit 500 offset #{offset}")
end

# Call List
puts "Porting call list entries"
ActiveRecord::Base.connection.execute('select * from call_list_entries_transfer').each do |cle|
  ported = CallListEntry.create! cle.except('id', 'fund_id', 'line_id', 'patient_id', 'user_id')
                           .merge({
                             'fund_id' => @fund_id,
                             'line_id' => @line_mappings[x['line_id']],
                             'patient_id' => @patient_mappings[x['patient_id']],
                             'user_id' => @user_mappings[x['user_id']]
                           })
  @call_list_entry_mappings[cle['id'].to_i] = ported.id
end

# Event
puts "Porting events"
ActiveRecord::Base.connection.execute('select * from events_transfer').each do |e|
  Event.create! e.except('id', 'fund_id', 'line_id', 'patient_id')
                 .merge({
                   'fund_id' => @fund_id,
                   'line_id' => @line_mappings[x['line_id']],
                   'patient_id' => @patient_mappings[x['patient_id']],
                 })
  @event_mappings[e['id'].to_i] = ported.id
end

# We don't care about sessions, since they're meant to be ephemeral anyway.
puts "not porting sessions because we don't care"

# Versions, on the other hand...
puts "porting versions"
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
      obj[key] = value_will_be_array ? v.map { |x| @fkey_mappings[k][x] } : @fkey_mappings[k][v]
    end
  end
  obj
end


# Transfer versions, porting keys along the way
offset = 0
versions = ActiveRecord::Base.connection.execute('select * from versions_transfer')
while versions.length > 0
  versions.each do |v|
    PaperTrailVersion.create! v.exclude('id', 'item_id', 'fund_id', 'object', 'object_changes', 'whodunnit')
                               .merge({
                                 'fund_id' => @fund_id,
                                 'item_id' => @item_type_mappings[v['item_type'][v['item_id']]],
                                 'whodunnit' => @user_mappings[v['whodunnit'].to_i],
                                 'object_changes' => transform_obj(v['object_changes'], v['item_type'], true),
                                 'object' => transform_obj(v['object'], v['item_type'], false)
                               })
  end

  # Do another batch
  offset = offset + 500
  puts "#{Time.now} Another batch of 500 pts"
  versions = ActiveRecord::Base.connection.execute('select * from versions_transfer')
end

puts "#{Time.zone.now} Completed"
