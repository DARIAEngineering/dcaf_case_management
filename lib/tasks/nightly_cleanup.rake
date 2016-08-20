desc 'Clean up call lists and urgent pregnancies'
task :nightly_cleanup do
  User.all.each { |user| user.clear_call_list }
  Pregnancy.trim_urgent_pregnancies
end
