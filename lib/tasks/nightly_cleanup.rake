desc 'Clean up call lists, unmark urgent patients, destroy old events'
task nightly_cleanup: :environment do
  User.all.each { |user| user.clear_call_list }
  puts "#{Time.now} -- cleared all recently reached patients from call lists"

  Patient.trim_urgent_patients
  puts "#{Time.now} -- trimmed urgent patients"

  Event.destroy_old_events
  puts "#{Time.now} -- destroyed old events"

  ArchivedPatient.process_dropped_off_patients
  puts "#{Time.now} -- archived dropped off patients"

  ArchivedPatient.process_fulfilled_patients
  puts "#{Time.now} -- archived fulfilled patients"

end
