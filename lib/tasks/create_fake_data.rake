namespace :db do
  namespace :seed do
    desc 'Generating fake patient entries for data wranglers'
    task :create_fake_data => :environment do

        users = User.all
        clinics = Clinic.all

        # TODO: We need to add calls, external pledges, 
        # practical supports, and fulfillments at the least, 
        # and also account for the fact that a lot of this stuff is 
        # naturally null.

        1000.times do |i|
          flag = (rand(10) % 5 == 0)

          initial_call = Date.today - rand(1000)
          
          has_appt = rand(3) % 2 == 0

          has_pledge = rand(3) != 2

          patient = Patient.create!(
            name: 'Randomized Patient',
            primary_phone: SecureRandom.random_number(10**10).to_s.rjust(10, '0'),
            initial_call_date: initial_call,
            created_by: users.sample(1).first,
            urgent_flag: flag,
            line: i.even? ? 'DC' : 'MD',
            clinic: has_appt ? clinics.sample(1).first : nil,
            appointment_date: has_appt ? initial_call + rand(30) : nil,
            last_menstrual_period_weeks: rand(15) + 7,
            last_menstrual_period_days: rand(7),
            procedure_cost: has_appt ? rand(600) : nil,
            pledge_sent: has_appt && has_pledge,
            patient_contribution: rand(400),
            fund_pledge: has_appt ? rand(300) : nil
          )

          # create external pledges
          if i.odd? && has_appt
            patient.external_pledges.create!(
            source: 'Metallica Abortion Fund',
            amount: 100,
            created_by: User.first
            )
          end
  
        end

    end   
  end
end