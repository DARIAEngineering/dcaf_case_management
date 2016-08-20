desc 'Clean up call lists and urgent pregnancies'
task nightly_cleanup: :environment do
  User.all.each { |user| user.clear_call_list }
  puts "#{Time.now} -- cleared all recently reached pregnancies from call lists"
  Pregnancy.trim_urgent_pregnancies
  puts "#{Time.now} -- trimmed urgent pregnancies"
end
