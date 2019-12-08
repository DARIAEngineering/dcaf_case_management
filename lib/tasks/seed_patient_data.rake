namespace :db do
  namespace :seed do
  end
end


# users = User.all
# clinics = Clinic.all

# 10000.times do |i|
#   flag = (rand(10) % 5 == 0)

#   initial_call = Date.today - rand(1000)

#   has_appt = rand(3) % 2 == 0

#   has_pledge = rand(3) != 2

#   patient = Patient.create!(
#     name: 'Randomized Patient',
#     primary_phone: "#{i}".rjust(10, '0'),
#     initial_call_date: initial_call,
#     urgent_flag: flag,
#     line: i.even? ? 'DC' : 'MD',
#     clinic: has_appt ? clinics.sample(1).first : nil,
#     created_by: users.sample(1).first,
#     appointment_date: has_appt ? initial_call + rand(30) : nil,
#     last_menstrual_period_weeks: rand(15) + 7,
#     last_menstrual_period_days: rand(7),
#     procedure_cost: has_appt ? rand(600) : nil,
#     pledge_sent: has_appt && has_pledge,
#     patient_contribution: rand(400),
#     fund_pledge: has_appt ? rand(300) : nil
#   )
# end