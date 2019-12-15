namespace :db do
  namespace :seed do
    desc 'Generate fake patient entries for data wranglers'
    task :create_fake_data => :environment do

        users = User.all
        clinics = Clinic.all

        5000.times do |idx|
          flag = idx % 5 == 0

          initial_call = Date.today - rand(300)
          
          has_appt = idx % 2 == 0

          has_pledge = idx % 3 == 0

          lines = ['DC', 'VA', 'MD'] # need to add Spanish maybe? 

          patient = Patient.create!(
            name: 'Randomized Patient',
            primary_phone: SecureRandom.random_number(10**10).to_s.rjust(10, "#{idx}"),
            initial_call_date: initial_call,
            created_by: users.sample(1).first,
            urgent_flag: flag,
            line: lines[idx%3], # thank you seeds.rb! 
            clinic: has_appt ? clinics.sample(1).first : nil,
            appointment_date: has_appt ? initial_call + rand(15) : nil,
            last_menstrual_period_weeks: rand(15) + 3,
            last_menstrual_period_days: rand(7),
            procedure_cost: has_appt ? rand(600) : nil,
            pledge_sent: has_appt && has_pledge,
            patient_contribution: rand(400),
            fund_pledge: has_appt ? rand(300) : nil
          )

          # create external_pledges, the conditional below simply attempts to 
          # maintain that not all callers will have an external pledge 
          if idx.odd? && has_appt
            patient.external_pledges.create!(
            source: 'Metallica Abortion Fund',
            amount: 100,
            created_by: users.sample
            )
          end

          # create calls, where every patient will have at least one call made
          call_status = ["Left voicemail", "Reached patient", "Couldn't reach patient"]

          rand(1..7).times do
            patient.calls.create status: call_status[rand(3)], created_by: users.sample
          end
          
          # create practical_support
          support_types = [
            'Companion', 
            'Lodging', 
            'Travel to the region', 
            'Travel inside the region', 
            'Other (see notes)']
          
          if has_appt && patient.procedure_cost > 500 && has_pledge
            patient.practical_supports.create!(
              source: 'Metallica Abortion Fund',
              support_type: support_types[rand(5)],
              created_by: users.sample
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

          # removing urgent flag if pledge sent, as I think this is what CMs typically do 
          if patient.pledge_sent
            patient.update(
              urgent_flag: false
            )
          end 
        
        end

        puts "Fake patients created! The database now has #{Patient.count} patients."

    end   
  end
end