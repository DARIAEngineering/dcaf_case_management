Call.destroy_all
Pregnancy.destroy_all
Patient.destroy_all
User.destroy_all

# Create two test users
user = User.create name: 'testuser', email: 'test@test.com',
                   password: 'P4ssword', password_confirmation: 'P4ssword'
user2 = User.create name: 'testuser2', email: 'test2@test.com',
                    password: 'P4ssword', password_confirmation: 'P4ssword'

# Create ten patients
10.times do |i|
  Patient.create name: "Patient #{i}",
                 primary_phone: "123-123-123#{i}",
                 created_by: user2
end

# Create active pregnancies for every patient
Patient.all.each do |patient|
  # If the patient number is even, flag as urgent
  if patient.name[-1, 1].to_i.even?
    flag = true
    lmp_weeks = (patient.name[-1, 1].to_i + 1) * 2
    lmp_days = 3
  else
    flag = false
  end

  # Create pregnancy
  creation_hash = { initial_call_date: 3.days.ago,
                    urgent_flag: flag,
                    last_menstrual_period_weeks: lmp_weeks,
                    last_menstrual_period_days: lmp_days,
                    created_by: user2
                  }

  pregnancy = patient.pregnancy.create creation_hash

  # Create calls for pregnancy
  5.times do
    pregnancy.calls.create status: 'Left voicemail',
                           created_at: 3.days.ago,
                           created_by: user2 unless patient.name == 'Patient 9'
  end

  if patient.name == 'Patient 0'
    10.times do
      pregnancy.calls.create status: 'Reached patient',
                             created_at: 3.days.ago,
                             created_by: user2
    end
  end
end

# Add a note to Patient 2
note_text = 'This is a note ' * 10
Patient.find_by(name: 'Patient 2')
       .pregnancies.first
       .notes.create full_text: note_text,
                     created_by: user2

# Adds Patients 0 thru 4 to regular call list
user.add_pregnancy Patient.find_by(name: 'Patient 0').pregnancy
user.add_pregnancy Patient.find_by(name: 'Patient 1').pregnancy
user.add_pregnancy Patient.find_by(name: 'Patient 2').pregnancy
user.add_pregnancy Patient.find_by(name: 'Patient 3').pregnancy
user.add_pregnancy Patient.find_by(name: 'Patient 4').pregnancy

# Add Patient 5 to completed calls list
patient_in_completed_calls = Patient.find_by(name: 'Patient 5')
                                    .pregnancies.first
user.add_pregnancy patient_in_completed_calls
patient_in_completed_calls.calls.create status: 'Left voicemail',
                                        created_by: user

# Log results
puts "Seed completed! Inserted #{Patient.count} patient objects" \
     "and #{Pregnancy.count} associated pregnancy objects.\n" \
     "User created! Credentials are as follows: " \
     "EMAIL: #{user.email} PASSWORD: P4ssword"
