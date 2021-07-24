# Set up fixtures and database seeds to simulate a production environment.
raise 'No running seeds in prod' unless [nil, 'Sandbox'].include? ENV['DARIA_FUND']

# Clear out existing DB
ActsAsTenant.without_tenant do
  Config.destroy_all
  Event.destroy_all
  Call.destroy_all
  CallListEntry.destroy_all
  ExternalPledge.destroy_all
  Fulfillment.destroy_all
  Note.destroy_all
  Patient.destroy_all
  ArchivedPatient.destroy_all
  User.destroy_all
  Clinic.destroy_all
  Fund.destroy_all
end

# Do versioning
PaperTrail.enabled = true

# Set a few config constants
lines = %w[DC VA MD]
note_text = 'This is a note ' * 10
additional_note_text = 'Additional note ' * 10
password = 'AbortionsAreAHumanRight1'

# Create a few test funds
fund1 = Fund.create! name: 'Cat Fund', domain: 'catfund.org', subdomain: 'catapp'
fund2 = Fund.create! name: 'Bigger Cat Fund', domain: 'catfund.org', subdomain: 'bigcatapp'

[fund1, fund2].each do |fund|
  ActsAsTenant.with_tenant(fund) do
    # Create test users
    user = User.create! name: 'testuser (admin)', email: 'test@example.com',
                        password: password, password_confirmation: password,
                        role: :admin
    user2 = User.create! name: 'testuser2', email: 'test2@example.com',
                         password: password, password_confirmation: password,
                         role: :cm
    User.create! name: 'testuser3', email: 'dcaf.testing@gmail.com',
                 password: password, password_confirmation: password,
                 role: :cm

    # Default to user2 as the actor
    PaperTrail.request.whodunnit = user2.id

    # Create a few clinics
    Clinic.create! name: 'Sample Clinic 1 - DC', street_address: '1600 Pennsylvania Ave',
                   city: 'Washington', state: 'DC', zip: '20500'
    Clinic.create! name: 'Sample Clinic 2 - VA', street_address: '1400 Defense',
                   city: 'Arlington', state: 'VA', zip: '20301'
    Clinic.create! name: 'Sample Clinic with NAF', street_address: '815 V Street NW',
                   city: 'Washington', state: 'DC', zip: '20001', accepts_naf: true
    Clinic.create! name: 'Sample Clinic without NAF', street_address: '1811 14th Street NW',
                   city: 'Washington', state: 'DC', zip: '20009', accepts_naf: false, accepts_medicaid: true

    # Create user-settable configuration
    Config.create config_key: :insurance,
                  config_value: { options: ['DC Medicaid', 'MD Medicaid', 'VA Medicaid', 'Other Insurance'] }
    Config.create config_key: :external_pledge_source,
                  config_value: { options: ['Baltimore Abortion Fund', 'Metallica Abortion Fund'] }
    Config.create config_key: :pledge_limit_help_text,
                  config_value: { options: ['Pledge Limit Guidelines:', '1st trimester (7-12 weeks): $100', '2nd trimester (12-24 weeks): $300', 'Later care (25+ weeks): $600'] }
    Config.create config_key: :language,
                  config_value: { options: %w[Spanish French Korean] }
    Config.create config_key: :resources_url,
                  config_value: { options: ['https://www.petfinder.com/cats/'] }
    Config.create config_key: :practical_support_guidance_url,
                  config_value: { options: ['https://www.petfinder.com/dogs/'] }
    Config.create config_key: :referred_by,
                  config_value: { options: ['Metal band'] }
    Config.create config_key: :fax_service,
                  config_value: { options: ['www.yolofax.com'] }
    Config.create config_key: :start_of_week,
                  config_value: { options: ['Monday'] }

    # Create ten active patients with generic info.
    10.times do |i|
      patient = Patient.create! name: "Patient #{i}",
                                primary_phone: "123-123-123#{i}",
                                initial_call_date: 3.days.ago,
                                urgent_flag: i.even?,
                                last_menstrual_period_weeks: (i + 1 * 2),
                                last_menstrual_period_days: 3,
                                line: 'DC'

      # Create associated objects
      case i
      when 0
        10.times do
          patient.calls.create! status: :reached_patient,
                                created_at: 3.days.ago
        end
      when 1
        PaperTrail.request(whodunnit: user.id) do
          patient.update! name: 'Other Contact info - 1', other_contact: 'Jane Doe',
                          other_phone: '234-456-6789', other_contact_relationship: 'Sister'
          patient.calls.create! status: :reached_patient,
                                created_at: 14.hours.ago
        end
      when 2
        # appointment one week from today && clinic selected
        patient.update! name: 'Clinic and Appt - 2',
                        zipcode: "20009",
                        pronouns: 'she/they',
                        clinic: Clinic.first,
                        appointment_date: 2.days.from_now
      when 3
        # pledge submitted
        patient.update! clinic: Clinic.first,
                        appointment_date: 3.days.from_now,
                        naf_pledge: 200,
                        procedure_cost: 400,
                        fund_pledge: 100,
                        pledge_sent: true,
                        patient_contribution: 100,
                        zipcode: "06222",
                        pronouns: 'ze/zir',
                        name: 'Pledge submitted - 3'
      when 4
        PaperTrail.request(whodunnit: user.id) do
          # With special circumstances
          patient.update! name: 'Special Circumstances - 4',
                          special_circumstances: ['Prison', 'Fetal anomaly']
          # And a recent call on file
          patient.calls.create! status: :left_voicemail
        end
      when 5
        # Resolved without DCAF
        patient.update! name: 'Resolved without DCAF - 5',
                        resolved_without_fund: true
      end

      if i != 9
        5.times do
          patient.calls.create! status: :left_voicemail,
                                created_at: 3.days.ago
        end
      end

      # Add notes for most patients
      unless [0, 1].include? i
        patient.notes.create! full_text: note_text
      end

      if i.even?
        patient.notes.create! full_text: additional_note_text
      end

      # Add select patients to call list for user
      user.add_patient patient if [0, 1, 2, 3, 4, 5].include? i

      patient.save
    end

    # Add patients for reporting purposes - CSV exports, fulfillments, etc.
    PaperTrail.request.whodunnit = user.id
    10.times do |i|
      patient = Patient.create!(
        name: "Reporting Patient #{i}",
        primary_phone: "321-0#{i}0-001#{rand(10)}",
        initial_call_date: 3.days.ago,
        urgent_flag: i.even?,
        line: i.even? ? 'DC' : 'MD',
        clinic: Clinic.all.sample,
        appointment_date: 10.days.from_now,
        last_menstrual_period_weeks: 7,
        last_menstrual_period_days: 7,
        naf_pledge: 300,
        fund_pledge: 50,
        procedure_cost: 600,
        pledge_sent: true,
        patient_contribution: 100
      )

      next unless i.even?

      patient.fulfillment.update fulfilled: true,
                                 fund_payout: 4000,
                                 procedure_date: 10.days.from_now
    end

    (1..5).each do |patient_number|
      patient = Patient.create!(
        name: "Reporting Patient #{patient_number}",
        primary_phone: "321-0#{patient_number}0-002#{rand(10)}",
        initial_call_date: 3.days.ago,
        urgent_flag: patient_number.even?,
        line: lines[patient_number % 3],
        clinic: Clinic.all.sample,
        appointment_date: 10.days.from_now
      )

      # reached within the past 30 days
      5.times do
        patient.calls.create! status: :reached_patient,
                              created_at: (Time.now - rand(10).days)
        patient.calls.create! status: :reached_patient,
                              created_at: (Time.now - rand(10).days - 10.days)
      end
    end

    (1..5).each do |patient_number|
      patient = Patient.create!(
        name: "Old Reporting Patient #{patient_number}",
        primary_phone: "321-0#{patient_number}0-003#{rand(10)}",
        initial_call_date: 3.days.ago,
        urgent_flag: patient_number.even?,
        line: lines[patient_number % 3],
        clinic: Clinic.all.sample,
        appointment_date: 10.days.from_now
      )

      5.times do
        patient.calls.create! status: :reached_patient,
                              created_at: (Time.now - rand(10).days - 6.months)
      end
    end

    (1..5).each do |patient_number|
      Patient.create!(
        name: "Pledge Reporting Patient #{patient_number}",
        primary_phone: "321-0#{patient_number}0-004#{rand(10)}",
        initial_call_date: 3.days.ago,
        urgent_flag: patient_number.even?,
        line: lines[patient_number % 3],
        clinic: Clinic.all.sample,
        appointment_date: 10.days.from_now,
        pledge_sent: true,
        fund_pledge: 50
      )
    end

    # Add patients for archiving purposes with ALL THE INFO
    (1..2).each do |patient_number|
      # initial create data from voicemail
      patient = Patient.create!(
        name: "Archive Dataful Patient #{patient_number}",
        primary_phone: "321-0#{patient_number}0-005#{rand(10)}",
        voicemail_preference: 'yes',
        line: 'DC',
        language: 'Spanish',
        initial_call_date: 140.days.ago,
        last_menstrual_period_weeks: 6,
        last_menstrual_period_days: 5,
        created_at: 140.days.ago
      )

      # Call, but no answer. leave a VM.
      patient.calls.create status: :left_voicemail, created_at: 139.days.ago

      # Call, which updates patient info, maybe flags urgent, make a note.
      patient.calls.create status: :reached_patient, created_at: 138.days.ago

      patient.update!(
        # header info - hand filled in
        appointment_date: 130.days.ago,

        # patient info - hand filled in
        age: 24,
        race_ethnicity: 'Hispanic/Latino',
        city: 'Washington',
        state: 'DC',
        county: 'Washington',
        other_contact: 'Susie Q.',
        other_phone: "555-0#{patient_number}0-0053",
        other_contact_relationship: 'Mother',
        employment_status: 'Student',
        income: '$10,000-14,999',
        household_size_adults: 3,
        household_size_children: 2,
        insurance: 'Other Insurance',
        referred_by: 'Clinic',
        special_circumstances: ['', '', 'Homelessness', '', '', 'Other medical issue', '', '', ''],

        # abortion info - hand filled in
        clinic: Clinic.all.sample,
        referred_to_clinic: patient_number.odd?,
        resolved_without_fund: patient_number.even?,

        updated_at: 138.days.ago # not sure if this even works?
      )

      # toggle urgent, maybe
      patient.update!(
        urgent_flag: patient_number.odd?,
        updated_at: 137.days.ago
      )

      # generate notes
      patient.notes.create!(
        full_text: 'One note, with iffy PII! This one was from the first call!',
        created_at: 137.days.ago
      )

      # only continue for the unresolved patient(s)
      next if patient.resolved_without_fund?

      # another call. get abortion information, create pledges, a note.
      patient.calls.create! status: :reached_patient, created_at: 136.days.ago

      # abortion info - pledges - hand filled in
      patient.update!(
        procedure_cost: 555,
        patient_contribution: 120,
        naf_pledge: 120,
        fund_pledge: 115,
        pledge_sent: true,
        pledge_generated_at: 133.days.ago,
        updated_at: 133.days.ago
      )
      # generate external pledges
      patient.external_pledges.create!(
        source: 'Metallica Abortion Fund',
        amount: 100,
        created_at: 133.days.ago
      )
      patient.external_pledges.create!(
        source: 'Baltimore Abortion Fund',
        amount: 100,
        created_at: 133.days.ago
      )

      # notes tab
      PaperTrail.request(whodunnit: user2.id) do
        patient.notes.create!(
          full_text: 'Two note, maybe with iffy PII! From the second call.',
          created_at: 133.days.ago
        )
      end

      # fulfillment
      patient.fulfillment.update!(
        fulfilled: true,
        procedure_date: 130.days.ago,
        gestation_at_procedure: '11',
        fund_payout: 555,
        check_number: 4563,
        date_of_check: 125.days.ago,
        updated_at: 125.days.ago
      )
    end

    (1..2).each do |patient_number|
      # Create dropoff patients
      patient = Patient.create!(
        name: "Archive Dropoff Patient #{patient_number}",
        primary_phone: "867-9#{patient_number}0-004#{rand(10)}",
        voicemail_preference: 'yes',
        line: 'DC',
        language: 'Spanish',
        initial_call_date: 640.days.ago,
        last_menstrual_period_weeks: 6,
        last_menstrual_period_days: 5,
        created_at: 640.days.ago
      )

      # Call, but no answer. leave a VM.
      patient.calls.create status: :left_voicemail, created_at: 639.days.ago

      # Call, which updates patient info, maybe flags urgent, make a note.
      patient.calls.create status: :reached_patient, created_at: 138.days.ago

      # Patient 1 drops off immediately
      next if patient_number.odd?

      # We reach Patient 2
      patient.update!(
        # header info - hand filled in
        appointment_date: 630.days.ago,

        # patient info - hand filled in
        age: 24,
        race_ethnicity: 'Hispanic/Latino',
        city: 'Washington',
        state: 'DC',
        county: 'Washington',
        zipcode: "20009",
        pronouns: 'they/them',
        other_contact: 'Susie Q.',
        other_phone: "555-6#{patient_number}0-0053",
        other_contact_relationship: 'Mother',

        employment_status: 'Student',
        income: '$10,000-14,999',
        household_size_adults: 3,
        household_size_children: 2,
        insurance: 'Other Insurance',
        referred_by: 'Clinic',
        special_circumstances: ['', '', 'Homelessness', '', '', 'Other medical issue', '', '', ''],

        # abortion info - hand filled in
        clinic: Clinic.all.sample,
        referred_to_clinic: patient_number.odd?,
        resolved_without_fund: patient_number.even?
      )

      # toggle urgent, maybe
      patient.update!(
        urgent_flag: patient_number.odd?,
        updated_at: 637.days.ago
      )

      # generate notes
      patient.notes.create!(
        full_text: 'One note, with iffy PII! This one was from the first call!',
        created_at: 637.days.ago
      )
    end
  end
end

# Log results
ActsAsTenant.without_tenant do
  puts "Seed completed! \n" \
       "Inserted #{Config.count} Config objects. \n" \
       "Inserted #{Event.count} Event objects. \n" \
       "Inserted #{Call.count} Call objects. \n" \
       "Inserted #{CallListEntry.count} CallListEntry objects. \n" \
       "Inserted #{ExternalPledge.count} ExternalPledge objects. \n" \
       "Inserted #{Fulfillment.count} Fulfillment objects. \n" \
       "Inserted #{Note.count} Note objects. \n" \
       "Inserted #{Patient.count} Patient objects. \n" \
       "Inserted #{ArchivedPatient.count} ArchivedPatient objects. \n" \
       "Inserted #{User.count} User objects. \n" \
       "Inserted #{Clinic.count} Clinic objects. \n" \
       "Inserted #{Fund.count} Fund objects. \n" \
       'User credentials are as follows: ' \
       "EMAIL: #{User.where(role: :admin).first.email} PASSWORD: #{password}"
end
