namespace :db do
  namespace :seed do
    desc 'Generate fake patient entries for data wranglers'
    task :create_fake_data => :environment do

        users = User.all
        clinics = Clinic.all

        5000.times do |idx|
          flag = (rand(10) % 5 == 0)

          initial_call = Date.today - rand(1000)
          
          has_appt = rand(3) % 2 == 0

          has_pledge = rand(3) != 2 

          lines = ['DC', 'VA', 'MD'] # need to add Spanish maybe? 

          patient = Patient.create!(
            name: 'Randomized Patient',
            primary_phone: SecureRandom.random_number(10**10).to_s.rjust(10, '0'), 
            initial_call_date: initial_call,
            created_by: users.sample(1).first,
            urgent_flag: flag,
            line: lines[idx%3], # thank you seeds.rb! 
            clinic: has_appt ? clinics.sample(1).first : nil,
            appointment_date: has_appt ? initial_call + rand(30) : nil,
            last_menstrual_period_weeks: rand(15) + 7,
            last_menstrual_period_days: rand(7),
            procedure_cost: has_appt ? rand(600) : nil,
            pledge_sent: has_appt && has_pledge,
            patient_contribution: rand(400),
            fund_pledge: has_appt ? rand(300) : nil
          )

          # create external_pledges
          if idx.odd? && has_appt
            patient.external_pledges.create!(
            source: 'Metallica Abortion Fund',
            amount: 100,
            created_by: User.first
            )
          end

          # create calls
          call_status = ["Left voicemail", "Reached patient", "Couldn't reach patient"]

          if idx.odd? && !has_appt
            rand(1..5).times do 
              patient.calls.create status: call_status[rand(3)], created_by: User.first
            end 
          elsif idx.even? && has_appt
            rand(1..7).times do
              patient.calls.create status: call_status[rand(3)], created_by: User.first
            end
          end
          
          # create practical_support
          support_types = [
            'Companion', 
            'Lodging', 
            'Travel to the region', 
            'Travel inside the region', 
            'Other (see notes)']
          
          if has_appt && patient.procedure_cost > 350 && has_pledge
            patient.practical_supports.create!(
              source: 'Metallica Abortion Fund',
              support_type: support_types[rand(5)],
              created_by: User.first
            )
          end 
          
          # create pledge fulfillments 
          if idx.even? && patient.pledge_sent 
            patient.build_fulfillment(
              created_by_id: User.first.id,
              fulfilled: true,
              fund_payout: patient.fund_pledge,
              procedure_date: patient.appointment_date
            ).save
          end 
        
        end

    end   
  end
end