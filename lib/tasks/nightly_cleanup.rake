desc 'Clean up call lists and urgent patients'
task nightly_cleanup: :environment do
  User.all.each { |user| user.clear_call_list }
  puts "#{Time.now} -- cleared all recently reached patients from call lists"
  Patient.trim_urgent_patients
  puts "#{Time.now} -- trimmed urgent patients"
end
