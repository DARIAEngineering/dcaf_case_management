desc 'Run nightly cleanup methods on call lists, users, patients, etc.'
task nightly_cleanup: :environment do
  # Run these tasks nightly
  Fund.all.each do |fund|
    ActsAsTenant.with_tenant(fund) do
      User.all.each { |user| user.clean_call_list_between_shifts }
      puts "#{Time.now} -- cleared all recently reached patients from call lists"

      User.disable_inactive_users
      puts "#{Time.now} -- locked accounts of users who have not logged in since #{User::TIME_BEFORE_DISABLED_BY_FUND.ago}"

      Patient.trim_urgent_patients
      puts "#{Time.now} -- trimmed urgent patients"

      ArchivedPatient.archive_eligible_patients!
      puts "#{Time.now} -- archived patients for today"
    end
  end

  Event.destroy_old_events
  puts "#{Time.now} -- destroyed old events"

  Rake::Task['db:sessions:trim'].invoke
  puts "#{Time.now} -- removed old sessions"

  if Time.zone.now.monday?
    # Run these events weekly
    Clinic.update_all_coordinates
    puts "#{Time.now} -- refreshed coordinates on all clinics"
  end
end
