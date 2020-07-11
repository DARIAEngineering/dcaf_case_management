class MongoArchivedPatient
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Userstamp
  extend Enumerize

  store_in collection: 'archived_patients'


  # Relationships
  belongs_to :clinic
  embeds_one :fulfillment
  embeds_many :calls
  embeds_many :external_pledges
  embeds_many :practical_supports, as: :can_support
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
  field :fund_pledged_at, type: Time
  field :pledge_sent, type: Boolean
  field :resolved_without_fund, type: Boolean
  field :pledge_generated_at, type: Time
  field :pledge_sent_at, type: Time
  field :textable, type: Boolean

  # Indices
  index(line: 1)
  index(identifier: 1)

  mongoid_userstamp user_model: 'User'
end
