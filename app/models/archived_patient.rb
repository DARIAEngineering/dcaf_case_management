class ArchivedPatient
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Userstamp

  # Relationships
  has_and_belongs_to_many :users, inverse_of: :patients
  belongs_to :clinic
  embeds_one :fulfillment
  embeds_many :calls
  embeds_many :external_pledges
  belongs_to :pledge_generated_by, class_name: 'User', inverse_of: nil
  belongs_to :pledge_sent_by, class_name: 'User', inverse_of: nil

  # Fields new on archive
  field :identifier, type: String # UUID, not phone number based!

  # Fields generated from initial patient info
  field :had_other_contact, type: Mongoid::Boolean
  field :age_range, type: Integer
  enumerize :age_range, in: [:under18, :age18-25, :age26-35, :age36-45, :age46-55, :age56-65, :age65plus, :not_specified], default: :not_specified

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
  validate :confirm_appointment_after_initial_call

  validates_associated :fulfillment

  # TODO do we want track history?
  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'

  # Archive & Delete patients who have fallen out of contact
  def self.process_dropped_off_patients
    Patient.where(:initial_call_date.lte => 1.year.ago).each do |patient|
      ArchivePatient.convert_patient(patient)
      #patient.destroy # TODO uncomment after initial testing
    end
  end

  # Archive & Delete patients who are completely through our process
  def self.process_fulfilled_patients
    Patient.fulfilled_on_or_before(120.days.ago) do |patient|
      ArchivePatient.convert_patient(patient)
      #patient.destroy # TODO uncomment after initial testing
    end
  end

  def self.convert_patient
    # do stuff here later but for now dinner!
  end
end
