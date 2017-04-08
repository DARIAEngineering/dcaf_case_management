fail 'No running seeds in prod' unless [nil, 'Test Sandbox'].include? ENV['FUND']

# if ARGV[1].blank?
#   puts "\n****SEED FAILED, but it's easy to fix****\n" \
#        "Rerun with your google account as an argument to create a Google SSO user\n" \
#        "Ex: `rake db:seed colin@gmail.com\n"
#   raise
# end

Patient.destroy_all
User.destroy_all
Clinic.destroy_all

# Create google SSO user
# puts "Creating user with email #{ARGV[1]}..."
# sso_user = User.create! email: ARGV[1], name: 'Development user',
#                         password: 'P4ssword', password_confirmation: 'P4ssword'

# Create two test users
user = User.create! name: 'testuser (admin)', email: 'test@test.com',
                   password: 'P4ssword', password_confirmation: 'P4ssword',
                   role: :admin
user2 = User.create! name: 'testuser2', email: 'test2@test.com',
                    password: 'P4ssword', password_confirmation: 'P4ssword'
user3 = User.create! name: 'testuser3', email: 'dcaf.testing@gmail.com',
                    password: 'P4ssword', password_confirmation: 'P4ssword'

# Create ten patients
10.times do |i|
  flag = i.even? ? true : false
  Patient.create! name: "Patient #{i}",
                 primary_phone: "123-123-123#{i}",
                 initial_call_date: 3.days.ago,
                 urgent_flag: flag,
                 created_by: user2
end

# Create active pregnancies for every patient
Patient.all.each do |patient|
  # If the patient number is even, flag as urgent
  if patient.name[-1, 1].to_i.even?
    lmp_weeks = (patient.name[-1, 1].to_i + 1) * 2
    lmp_days = 3
  end

  # Create pregnancy
  creation_hash = { last_menstrual_period_weeks: lmp_weeks,
                    last_menstrual_period_days: lmp_days,
                    created_by: user2
                  }

  pregnancy = patient.build_pregnancy(creation_hash)
  pregnancy.save
  patient.build_fulfillment(created_by_id: User.first.id).save

  # Create calls for pregnancy
  5.times do
    patient.calls.create! status: 'Left voicemail',
                          created_at: 3.days.ago,
                          created_by: user2 unless patient.name == 'Patient 9'
  end

  if patient.name == 'Patient 0'
    10.times do
      patient.calls.create! status: 'Reached patient',
                            created_at: 3.days.ago,
                            created_by: user2
    end
  end

  # Add example of patient with other contact info
  if patient.name == 'Patient 1'
    patient.update! name: "Other Contact info - 1", other_contact: "Jane Doe",
                   other_phone: "234-456-6789", other_contact_relationship: "Sister"
    patient.calls.create! status: 'Reached patient',
                          created_at: 14.hours.ago,
                          created_by: user
  end

  # Add example of patient with appointment one week from today && clinic selected
  if patient.name == 'Patient 2'
    patient.update! name: "Clinic and Appt - 2",
                    clinic_name: "Sample Clinic 1",
                    appointment_date: (1.week.from_now)
  end

  # Add example of patient with a pledge submitted
  if patient.name == 'Patient 3'
    patient.update! clinic_name: "Sample Clinic 1",
                    appointment_date: 10.days.from_now
    patient.pregnancy.update! naf_pledge: 2000,
                             procedure_cost: 4000,
                             procedure_date: 1.week.from_now,
                             dcaf_soft_pledge: 1000,
                             pledge_sent: true,
                             patient_contribution: 1000,
                             created_by: user2
    patient.update! name: "Pledge submitted - 3"
  end

  # Add example of patient should have special circumstances
  if patient.name == 'Patient 4'
    patient.update! name: "Special Circumstances - 4",
                   special_circumstances: ["Prison", "Fetal anomaly"]
  end

  # Add example of patient should be marked resolved without DCAF
  if patient.name == 'Patient 5'
    patient.pregnancy.update! resolved_without_dcaf: true
    patient.update! name: "Resolved without DCAF - 5"
  end

  patient.save
end

# All patients except one or two should have notes, even numbered patients have two notes
note_text = 'This is a note ' * 10
additional_note_text = 'Additional note ' * 10
Patient.all.each do |patient|
  unless patient.name == "Patient 0" || patient.name == "Other Contact info - 1"
    patient.notes.create! full_text: note_text,
                          created_by: user2
  end
  if patient.name[-1, 1].to_i.even?
    patient.notes.create! full_text: additional_note_text,
                          created_by: user2
  end
end

# Adds 5 Patients to regular call list
['Patient 0', 'Other Contact info - 1',
 'Clinic and Appt - 2',
 'Pledge submitted - 3',
 'Resolved without DCAF - 5'].each do |patient_name|
  user.add_patient Patient.find_by name: patient_name
end

# Add Patient to completed calls list
patient_in_completed_calls =
  Patient.find_by name: 'Special Circumstances - 4'
user.add_patient patient_in_completed_calls
patient_in_completed_calls.calls.create! status: 'Left voicemail',
                                        created_by: user

# Seed a pair of clinics, Sample 1 and Sample 2
Clinic.create! name: 'Sample Clinic 1 - DC', street_address: '123 Fake Street',
               city: 'Washington', state: 'DC', zip: '20011'
Clinic.create! name: 'Sample Clinic 2 - VA', street_address: '123 Fake Street',
               city: 'Arlington', state: 'DC', zip: '22204'
Clinic.create! name: 'Sample Clinic with NAF', street_address: '123 Fake Street',
               city: 'Washington', state: 'DC', zip: '20011', accepts_naf: true
Clinic.create! name: 'Sample Clinic without NAF', street_address: '123 Fake Street',
               city: 'Washington', state: 'DC', zip: '20011', accepts_naf: false


# Log results
puts "Seed completed! Inserted #{Patient.count} patient objects. \n" \
     "Inserted #{Clinic.count} clinic objects. \n" \
     "User created! Credentials are as follows: " \
     "EMAIL: #{user.email} PASSWORD: P4ssword"
     # "GOOGLE ACCOUNT: #{sso_user.email}" # We're depreciating password in favor of SSO

# exit # so it doesn't try to run other rake tasks
