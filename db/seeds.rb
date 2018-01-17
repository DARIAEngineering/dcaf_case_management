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

# Seed a pair of clinics, Sample 1 and Sample 2
Clinic.create! name: 'Sample Clinic 1 - DC', street_address: '1600 Pennsylvania Ave',
               city: 'Washington', state: 'DC', zip: '20500'
Clinic.create! name: 'Sample Clinic 2 - VA', street_address: '1400 Defense',
               city: 'Arlington', state: 'VA', zip: '20301'
Clinic.create! name: 'Sample Clinic with NAF', street_address: '815 V Street NW',
              city: 'Washington', state: 'DC', zip: '20001', accepts_naf: true
Clinic.create! name: 'Sample Clinic without NAF', street_address: '1811 14th Street NW',
              city: 'Washington', state: 'DC', zip: '20009', accepts_naf: false, accepts_medicaid: true


# Create ten patients
10.times do |i|
  flag = i.even? ? true : false
  Patient.create! name: "Patient #{i}",
                 primary_phone: "123-123-123#{i}",
                 initial_call_date: 3.days.ago,
                 urgent_flag: flag,
                 last_menstrual_period_weeks: (i + 1 * 2),
                 last_menstrual_period_days: 3,
                 created_by: user2
end

# Create associated objects
Patient.all.each do |patient|
  # Create calls for patient
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
                    clinic: Clinic.first,
                    appointment_date: (1.week.from_now)
  end

  # Add example of patient with a pledge submitted
  if patient.name == 'Patient 3'
    patient.update! clinic: Clinic.first,
                    appointment_date: 10.days.from_now,
                    naf_pledge: 2000,
                    procedure_cost: 4000,
                    fund_pledge: 1000,
                    pledge_sent: true,
                    patient_contribution: 1000,
                    name: "Pledge submitted - 3"
  end

  # Add example of patient should have special circumstances
  if patient.name == 'Patient 4'
    patient.update! name: "Special Circumstances - 4",
                    special_circumstances: ["Prison", "Fetal anomaly"]
  end

  # Add example of patient should be marked resolved without DCAF
  if patient.name == 'Patient 5'
    patient.update! name: "Resolved without DCAF - 5",
                    resolved_without_fund: true
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

# Create insurance and external pledge source keysets
Config.destroy_all
Config.create config_key: :insurance,
              config_value: { options: ['DC Medicaid', 'MD Medicaid', 'VA Medicaid', 'Other Insurance']}
Config.create config_key: :external_pledge_source,
              config_value: { options: ['Baltimore Abortion Fund', 'Metallica Abortion Fund']}
Config.create config_key: :pledge_limit_help_text,
              config_value: { options: ['Pledge Limit Guidelines:', '1st trimester (7-12 weeks): $100', '2nd trimester (12-24 weeks): $300', 'Later care (25+ weeks): $600']}
Config.create config_key: :language,
              config_value: { options: ['Spanish', 'French', 'Korean']}

# Reporting fixtures
# Add some patients with pledges some of whom have
# fulfillments for reporting testing for fulfillments
10.times do |i|
  flag = i.even? ? true : false

  patient = Patient.create!(
    name: "Reporting Patient #{i}",
    primary_phone: "321-0#{i}0-001#{rand(10)}",
    initial_call_date: 3.days.ago,
    urgent_flag: flag,
    line: i.even? ? 'DC' : 'MD',
    created_by: User.first,
    clinic: Clinic.all.sample,
    appointment_date: 10.days.from_now,
    last_menstrual_period_weeks: 7,
    last_menstrual_period_days: 7,
    naf_pledge: 300,
    fund_pledge: 200,
    procedure_cost: 600,
    pledge_sent: true,
    patient_contribution: 100)

  if i.even?
    patient.build_fulfillment(
      created_by_id: User.first.id,
      fulfilled: true,
      procedure_cost: 4000,
      procedure_date: 10.days.from_now
    ).save
  end
end

# Add some patients with calls for call reporting
lines = ['DC', 'VA', 'MD']
(1..5).each do |patient_number|
  patient = Patient.create!(
    name: "Reporting Patient #{patient_number}",
    primary_phone: "321-0#{patient_number}0-002#{rand(10)}",
    initial_call_date: 3.days.ago,
    urgent_flag: patient_number.even? ? true : false,
    line: lines[patient_number%3],
    created_by: User.first,
    clinic: Clinic.all.sample,
    appointment_date: 10.days.from_now)

  # reached calls this month
  5.times do
    Call.create!(
      patient: patient,
      status: 'Reached patient',
      created_by: User.first,
      created_at: (Time.now - rand(10).days))
  end

  5.times do
    Call.create!(
      patient: patient,
      status: 'Reached patient',
      created_by: User.first,
      created_at: (Time.now - rand(10).days - 10.days))
  end
end

# we'll create 5 patients with calls this year
(1..5).each do |patient_number|
  patient = Patient.create!(
    name: "Old Reporting Patient #{patient_number}",
    primary_phone: "321-0#{patient_number}0-003#{rand(10)}",
    initial_call_date: 3.days.ago,
    urgent_flag: patient_number.even? ? true : false,
    line: lines[patient_number%3],
    created_by: User.first,
    clinic: Clinic.all.sample,
    appointment_date: 10.days.from_now)

  # rcalls this year
  5.times do
    Call.create!(
      patient: patient,
      status: 'Reached patient',
      created_by: User.first,
      created_at: (Time.now - rand(10).days - 6.months))
  end
end

# we'll create 5 patients with pledges at different times
(1..5).each do |patient_number|
  patient = Patient.create!(
    name: "Pledge Reporting Patient #{patient_number}",
    primary_phone: "321-0#{patient_number}0-004#{rand(10)}",
    initial_call_date: 3.days.ago,
    urgent_flag: patient_number.even? ? true : false,
    line: lines[patient_number%3],
    created_by: User.first,
    clinic: Clinic.all.sample,
    appointment_date: 10.days.from_now,
    pledge_sent: true,
    fund_pledge: 1000)
end

# create patients with ALL THE INFO to play with archiving
(1..3).each do |patient_number|
  # initial create data from voicemail
  patient = Patient.create!(
    name: "Archive Dataful Patient #{patient_number}",
    primary_phone: "321-0#{patient_number}0-004#{rand(10)}",
    voicemail_preference: "yes",
    line: 'DC',
    language: "Spanish",
    initial_call_date: 90.days.ago,
    last_menstrual_period_weeks: 6,
    last_menstrual_period_days: 5,
    created_by: User.first,
    created_at: 90.days.ago,
  )

  # Call, but no answer. leave a VM.

  patient.calls.create status: 'Left voicemail', created_by: User.first, created_at: 90.days.ago

  # Call, which updates patient info, maybe flags urgent, make a note.
  patient.calls.create status: 'Reached patient', created_by: User.first, created_at: 89.days.ago

  patient.update!(
    # header info - hand filled in
    appointment_date: 60.days.ago,

    # patient info - hand filled in
    age: 24,
    race_ethnicity: "Hispanic/Latino",
    city: "Washington",
    state: "DC",
    county: "Washington",
    other_contact: "Susie Q.",
    other_phone: "555-0#{patient_number}0-0053",
    other_contact_relationship: "Mother",

    employment_status: "Student",
    income: "$10,000-14,999",
    household_size_adults: 3,
    household_size_children: 2,
    insurance: "Other Insurance",
    referred_by: "Clinic",
    special_circumstances: ["", "", "Homelessness", "", "", "Other medical issue", "", "", ""],

    # abortion info - hand filled in
    clinic: Clinic.all.sample,
    referred_to_clinic:  patient_number.odd? ? true : false,
    resolved_without_fund:  patient_number.even? ? true : false,

    updated_at: 89.days.ago, #not sure if this even works?
  )

  # notes tab
  # toggle urgent, maybe
  patient.update!(
    urgent_flag: patient_number.odd? ? true : false,
    updated_at: 89.days.ago,
  )
  # generate notes
  patient.notes.create!(
    full_text: "One note, with iffy PII! This one was from the first call!",
    created_by: user,
    created_at: 89.days.ago,
  )

  # only continue for the unresolved patient(s)
  next if patient.resolved_without_fund?

  # another call. get abortion information, create pledges, a note.
  patient.calls.create status: 'Reached patient', created_by: User.first, created_at: 81.days.ago

  # abortion info - pledges - hand filled in
  patient.update!(
    procedure_cost: 555,
    patient_contribution: 120,
    naf_pledge: 120,
    fund_pledge: 115,
    pledge_sent: true,
    pledge_generated_at: 70.days.ago,
    pledge_generated_by: User.first,
    updated_at: 81.days.ago,
  )
  # generate external pledges
  patient.external_pledges.create!(
    source: 'Metallica Abortion Fund',
    amount: 100,
    created_by: user,
    created_at: 81.days.ago,
  );
  patient.external_pledges.create!(
    source: 'Baltimore Abortion Fund',
    amount: 100,
    created_by: user,
    created_at: 81.days.ago,
  );

  # notes tab
  patient.notes.create!(
    full_text: "Two note, maybe with iffy PII! From the second call.",
    created_by: user2,
    created_at: 81.days.ago,
  )

  # fulfillment

  patient.fulfillment.update!(
    fulfilled: true,
    procedure_date: (patient_number * 80).days.ago,
    gestation_at_procedure: "11",
    procedure_cost: 555,
    check_number: 4563,
    date_of_check: (patient_number * 90).days.ago,
    updated_at: (patient_number * 88).days.ago,
  )

end



# Log results
puts "Seed completed! Inserted #{Patient.count} patient objects. \n" \
     "Inserted #{Clinic.count} clinic objects. \n" \
     "User created! Credentials are as follows: " \
     "EMAIL: #{user.email} PASSWORD: P4ssword"
     # "GOOGLE ACCOUNT: #{sso_user.email}" # We're depreciating password in favor of SSO

# exit # so it doesn't try to run other rake tasks
