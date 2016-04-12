Call.destroy_all
Pregnancy.destroy_all
Patient.destroy_all
User.destroy_all

user = User.create name: 'testuser', email: 'test@test.com', password: 'password', password_confirmation: 'password'

10.times do |i|
  Patient.create({name: "Patient #{i}", primary_phone: "123-123-123#{i}"})
end

patients = Patient.all

patients.each do |patient|
  if(patient.name[-1, 1].to_i.even?) then
    flag = true
  else
    flag = false
  end
  patient.pregnancies.create({last_menstrual_period_time: DateTime.new(2016,1,1), urgent_flag: flag})
end

puts "Seed completed! Inserted #{Patient.count} patient objects and #{Pregnancy.count} associated pregnancy objects."
puts "User created! Credentials are as follows: EMAIL: #{user.email} PASSWORD: password"
