Call.destroy_all
Pregnancy.destroy_all
Patient.destroy_all
User.destroy_all

user = User.create name: 'testuser', email: 'test@test.com', password: 'password', password_confirmation: 'password'

10.times do |i|
  Patient.create name: "Patient #{i}", primary_phone: "123-123-123#{i}", created_by: user
end

Patient.all.each do |patient|
  if patient.name[-1, 1].to_i.even?
    flag = true
    lmp_weeks = (patient.name[-1, 1].to_i + 1) * 2
    lmp_days = 3
  else
    flag = false
  end
  pregnancy = patient.pregnancies.create initial_call_date: Time.zone.today, 
                                         urgent_flag: flag, 
                                         last_menstrual_period_weeks: lmp_weeks,
                                         last_menstrual_period_days: lmp_days,
                                         created_by: user.id

  5.times do
    pregnancy.calls.create status: 'Left voicemail', created_by: user unless patient.name == 'Patient 9'
  end
  if patient.name == 'Patient 0'
    10.times do
      pregnancy.calls.create status: 'Reached patient', created_by: user
    end
  end
end

puts "Seed completed! Inserted #{Patient.count} patient objects and #{Pregnancy.count} associated pregnancy objects."
puts "User created! Credentials are as follows: EMAIL: #{user.email} PASSWORD: password"
