class ArchivedPatient
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Userstamp
  extend Enumerize

  # Concerns
  include Exportable

  # Relationships
  belongs_to :clinic
  embeds_one :fulfillment
  embeds_many :calls
  embeds_many :external_pledges
  belongs_to :pledge_generated_by, class_name: 'User', inverse_of: nil
  belongs_to :pledge_sent_by, class_name: 'User', inverse_of: nil

  # Fields new on archive
  field :identifier, type: String # UUID, not phone number based!

  # Fields generated from initial patient info
  field :has_alt_contact, type: Mongoid::Boolean
  field :age_range
  enumerize :age_range, in: [:not_specified, :under_18, :age18_24, :age25_34, :age35_44, :age45_54, :age55plus, :bad_value], default: :not_specified

  # Fields pulled from initial Patient
  field :voicemail_preference
  enumerize :voicemail_preference, in: [:not_specified, :no, :yes], default: :not_specified
  field :line
  enumerize :line, in: LINES, default: LINES[0] # See config/initializers/env_vars.rb
  field :language, type: String
  field :initial_call_date, type: Date
  field :urgent_flag, type: Boolean
  field :last_menstrual_period_weeks, type: Integer
  field :last_menstrual_period_days, type: Integer
  field :city, type: String
  field :state, type: String
  field :county, type: String
  field :race_ethnicity, type: String
  field :employment_status, type: String
  field :insurance, type: String
  field :income, type: String
  field :notes_count, type: Integer
  field :has_special_circumstances, type: Boolean
  field :referred_by, type: String
  field :referred_to_clinic, type: Boolean
  field :appointment_date, type: Date
  field :procedure_cost, type: Integer
  field :patient_contribution, type: Integer
  field :naf_pledge, type: Integer
  field :fund_pledge, type: Integer
  field :pledge_sent, type: Boolean
  field :resolved_without_fund, type: Boolean
  field :pledge_generated_at, type: Time
  field :pledge_sent_at, type: Time

  # Indices
  index(line: 1)
  index(identifier: 1)

  # Validations
  validates :initial_call_date,
            :created_by_id,
            :line,
            presence: true
  validates :appointment_date, format: /\A\d{4}-\d{1,2}-\d{1,2}\z/,
                               allow_blank: true

  validates_associated :fulfillment


  mongoid_userstamp user_model: 'User'

  # Archive & delete audited patients who called a year or more ago, or any
  # from two plus years ago
  def self.archive_todays_patients!
    Patient.where(:archive_date.lte => Date.today).each do |patient|
      if (patient.audited_or_obsolete?)
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

      pledge_sent: patient.pledge_sent,
      resolved_without_fund: patient.resolved_without_fund,
      pledge_generated_at: patient.pledge_generated_at,
      pledge_sent_at: patient.pledge_sent_at,

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
