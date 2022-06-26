namespace :db do
  namespace :seed do
    desc 'Generate fake patient entries for data wranglers'
    task :create_fake_data => :environment do

        ActsAsTenant.current_tenant = Fund.first
        users = User.all
        clinics = Clinic.all

        gen = Random.new(2020) # our random number generator: https://ruby-doc.org/core-2.7.0/Random.html

        5000.times do |idx|
          idx % 10 == 0 ? print("\nMaking fake pt #{idx} of 5000") : print('.')
          flag = gen.rand < 0.05 # gen.rand will always return a float between 0 and 1 

          initial_call = Date.today - gen.rand(300)
          
          has_appt = gen.rand < 0.8

          has_pledge = gen.rand < 0.5

          lines = Line.all # need to add Spanish maybe? 

          patient = Patient.create!(
            name: 'Randomized Patient',
            primary_phone: "#{idx}".rjust(10, "0"),
            initial_call_date: initial_call,
            created_by: users.sample,
            shared_flag: flag,
            line: lines[gen.rand(3)], # thank you seeds.rb! 
            clinic: has_appt ? clinics.sample : nil,
            appointment_date: has_appt ? initial_call + gen.rand(15) : nil,
            last_menstrual_period_weeks: gen.rand(15) + 3,
            last_menstrual_period_days: gen.rand(7),
            procedure_cost: has_appt ? gen.rand(600) : nil,
            pledge_sent: has_appt && has_pledge,
            patient_contribution: gen.rand(400),
            fund_pledge: has_appt ? gen.rand(300) : nil
          )

          # create external_pledges, the conditional below simply attempts to 
          # maintain that not all callers will have an external pledge 
          if gen.rand < 0.3 && has_appt
            patient.external_pledges.create!(
            source: 'Metallica Abortion Fund',
            amount: 100,
            created_by: users.sample
            )
          end

          # create calls, where every patient will have at least one call made
          call_status = [:left_voicemail, :reached_patient, :couldnt_reach_patient]

          gen.rand(1..7).times do
            patient.calls.create status: call_status[gen.rand(3)], created_by: users.sample
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
              support_type: support_types[gen.rand(5)],
              created_by: users.sample
            )
          end 
          
          # create pledge fulfillments, with 75 percent probability!?
          if gen.rand < 0.75 && patient.pledge_sent 
            patient.build_fulfillment(
              created_by_id: User.first.id,
              fulfilled: true,
              fund_payout: patient.fund_pledge,
              procedure_date: patient.appointment_date
            ).save
          end 

          # removing shared flag if pledge sent, as I think this is what CMs typically do 
          patient.update(shared_flag: false) unless !patient.pledge_sent
        
        end

        puts "Fake patients created! The database now has #{Patient.count} patients."

    end   
  end
end
