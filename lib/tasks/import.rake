# note: rough outline of import code. 
# namespace :import do
  # desc 'Import data from CSV. NOTE: NOT PRODUCTION READY' do
    # require 'csv'


    # if(!ARGV[1].nil?)
    #   CSV.foreach(File.path(ARGV[1]), :headers => true) do |row|
    #     patient = Patient.create name: row[0], primary_phone: row[1], created_by: user
    #     pregnancy = patient.pregnancies.create initial_call_date: row[2],
    #                                 urgent_flag: row[3],
    #                                last_menstrual_period_weeks: row[4],
    #                                last_menstrual_period_days: row[5],
    #                                created_by: user.id
    #     Integer(row[6]).times do
    #       pregnancy.calls.create status: 'Left voicemail', created_by: user
    #     end
    #     Integer(row[7]).times do
    #       pregnancy.calls.create status: 'Reached patient', created_by: user
    #     end
    #   end
    # end

    # if(ARGV[1].nil?)
    #   10.times do |i|
    #     Patient.create name: "Patient #{i}", primary_phone: "123-123-123#{i}", created_by: user
    #   end

    #   Patient.all.each do |patient|
    #     if patient.name[-1, 1].to_i.even?
    #       flag = true
    #       lmp_weeks = (patient.name[-1, 1].to_i + 1) * 2
    #       lmp_days = 3
    #     else
    #       flag = false
    #     end

    #     pregnancy = patient.pregnancies.create initial_call_date: Time.zone.today, 
    #                                            urgent_flag: flag, 
    #                                            last_menstrual_period_weeks: lmp_weeks,
    #                                            last_menstrual_period_days: lmp_days,
    #                                            created_by: user.id

    #     5.times do
    #       pregnancy.calls.create status: 'Left voicemail', created_by: user unless patient.name == 'Patient 9'
    #     end
    #     if patient.name == 'Patient 0'
    #       10.times do
    #         pregnancy.calls.create status: 'Reached patient', created_by: user
    #       end
    #     end
    #   end
    # end
  # end
# end


# Name,primary_phone,initial_call_date,urgent_flag,last_menstrual_period_weeks,last_menstrual_period_days,left_voicemail_num,reached_patient_num
# Patient McPatient,202-363-1226,"Sat, 27 Oct 2012",TRUE,2,1,1,0
# Jane Doe,202-385-3902,"Sat, 27 Oct 2012",FALSE,3,2,0,2
# Dough Jain,202-135-3859,"Sat, 27 Oct 2012",TRUE,4,3,3,1
