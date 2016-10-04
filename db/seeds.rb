Patient.destroy_all
User.destroy_all
Clinic.destroy_all

# Create two test users
user = User.create name: 'testuser', email: 'test@test.com',
                   password: 'P4ssword', password_confirmation: 'P4ssword'
user2 = User.create name: 'testuser2', email: 'test2@test.com',
                    password: 'P4ssword', password_confirmation: 'P4ssword'

# Create ten patients
10.times do |i|
  flag = i.even? ? true : false
  Patient.create name: "Patient #{i}",
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
end

# Patients should have names that reflect what we're looking for (e.g. 'Patient With Other Contact' rather than 'Patient 2')
# Add example of patient with other contact info
  patient1 = Patient.find_by( name: "Patient 1")
  patient1.update_attributes( name: "Patient with Other Contact info - 1", other_contact: "Jane Doe", other_phone: "234-456-6789", other_contact_relationship: "Sister" )
  patient1.save!

# Add example of patient with appointment one week from today && clinic selected
  patient2 = Patient.find_by( name: "Patient 2")
  patient2.update_attributes( name: "Patient with clinic and appointment(1wk) - 2",clinic_name: "Sample Clinic 1", appointment_date: Time.now + (7*24*60*60) )
  patient2.save!

# # Add example of patient with a pledge submitted
  patient3 = Patient.find_by( name: "Patient 3")
  pledge = patient3.pledges.new()
    pledge.created_by = user2
    pledge.pledge_type = "naf"
    pledge.amount = "3000"
    pledge.save!
  patient3.update_attributes( name: "Patient with a pledge submitted - 3", clinic_name: "Sample Clinic 1", appointment_date: Time.now + (10*24*60*60) )
  patient3.save!  


# # Add example of patient should be marked resolved without DCAF
  patient5 = Patient.find_by( name: "Patient 5")
  patient5.pregnancy.resolved_without_dcaf = true
  patient5.update_attributes( name: "Patient resolved without DCAF - 5")
  patient5.save!  


# Add example of patient should have special circumstances
  patient4 = Patient.find_by( name: "Patient 4")
  patient4.update_attributes( name: "Patient with Special Circumstances - 4", special_circumstances: ["Prison", "Fetal anomaly"] )
  patient4.save!  

# All patients except one or two should have notes
note_text = 'This is a note ' * 10
additional_note_text = 'Additional note ' * 10
Patient.all.each do |patient|
  unless patient.name == "Patient 0" || patient.name == "Patient 1 with Other Contact info"
    patient.notes.create! full_text: note_text,
                  created_by: user2
  end
  if patient.name[-1, 1].to_i.even?
    patient.notes.create! full_text: additional_note_text,
                  created_by: user2
  end
end

# Adds Patients 0 thru 4 to regular call list
user.add_patient Patient.find_by(name: 'Patient 0')
user.add_patient Patient.find_by(name: 'Patient with Other Contact info - 1')
user.add_patient Patient.find_by(name: 'Patient with clinic and appointment(1wk) - 2')
user.add_patient Patient.find_by(name: 'Patient with a pledge submitted - 3')
user.add_patient Patient.find_by(name: 'Patient resolved without DCAF - 5')

# Add Patient 5 to completed calls list
patient_in_completed_calls = Patient.find_by(name: 'Patient with Special Circumstances - 4')
user.add_patient patient_in_completed_calls
patient_in_completed_calls.calls.create status: 'Left voicemail',
                                        created_by: user

# Log results
puts "Seed completed! Inserted #{Patient.count} patient objects" \
     "and #{Pregnancy.count} associated pregnancy objects.\n" \
     "User created! Credentials are as follows: " \
     "EMAIL: #{user.email} PASSWORD: P4ssword"
