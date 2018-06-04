desc 'Clean up call lists, unmark urgent patients, destroy old events'
task nightly_cleanup: :environment do
  User.all.each { |user| user.clean_call_list_between_shifts }
  puts "#{Time.now} -- cleared all recently reached patients from call lists"

  User.disable_inactive_users
  puts "#{Time.now} -- locked accounts of users who have not logged in since #{User::TIME_BEFORE_DISABLED_BY_FUND.ago}"

  Patient.trim_urgent_patients
  puts "#{Time.now} -- trimmed urgent patients"

  Event.destroy_old_events
  puts "#{Time.now} -- destroyed old events"

  ArchivedPatient.archive_dropped_off_patients!
  puts "#{Time.now} -- archived dropped off patients"

  ArchivedPatient.archive_fulfilled_patients!
  puts "#{Time.now} -- archived fulfilled patients"
end
