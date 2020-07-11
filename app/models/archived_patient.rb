class ArchivedPatient < MongoArchivedPatient
  include Exportable
  include LastMenstrualPeriodMeasureable

  # Validations
  validates :initial_call_date,
            :created_by_id,
            :line,
            presence: true
  validates :appointment_date, format: /\A\d{4}-\d{1,2}-\d{1,2}\z/,
                               allow_blank: true

  validates_associated :fulfillment

  # Archive & delete audited patients who called a several months ago, or any
  # from a year plus ago
  def self.archive_eligible_patients!
    Patient.all.each do |patient|
      if ( patient.archive_date < Date.today )
        ArchivedPatient.convert_patient(patient)
        patient.destroy!
      end
    end
  end

  def self.convert_patient(patient)
    archived_patient = new(
      line: patient.line,
      city: patient.city,
      state: patient.state,
      county: patient.county,
      initial_call_date: patient.initial_call_date,
      appointment_date: patient.appointment_date,

      urgent_flag: patient.urgent_flag,
      referred_by: patient.referred_by,
      referred_to_clinic: patient.referred_to_clinic,

      last_menstrual_period_weeks: patient.last_menstrual_period_weeks,
      last_menstrual_period_days: patient.last_menstrual_period_days,

      race_ethnicity: patient.race_ethnicity,
      employment_status: patient.employment_status,
      insurance: patient.insurance,
      income: patient.income,
      language: patient.language,
      voicemail_preference: patient.voicemail_preference,

      procedure_cost: patient.procedure_cost,
      patient_contribution: patient.patient_contribution,
      naf_pledge: patient.naf_pledge,
      fund_pledge: patient.fund_pledge,
      fund_pledged_at: patient.fund_pledged_at,

      pledge_sent: patient.pledge_sent,
      resolved_without_fund: patient.resolved_without_fund,
      pledge_generated_at: patient.pledge_generated_at,
      pledge_sent_at: patient.pledge_sent_at,
      textable: patient.textable,

      pledge_generated_by: patient.pledge_generated_by,
      pledge_sent_by: patient.pledge_sent_by,
      created_by_id: patient.created_by_id,

      age_range: patient.age_range,
      has_alt_contact: patient.has_alt_contact,
      notes_count: patient.notes_count,
      has_special_circumstances: patient.has_special_circumstances,

    )

    archived_patient.fulfillment = patient.fulfillment.clone
    archived_patient.clinic_id = patient.clinic_id if patient.clinic_id
    patient.calls.each do |call|
      archived_patient.calls.new(call.clone.attributes)
    end
    patient.external_pledges.each do |ext_pledge|
      archived_patient.external_pledges.new(ext_pledge.clone.attributes)
    end

    archived_patient.save!
    archived_patient
  end
end
