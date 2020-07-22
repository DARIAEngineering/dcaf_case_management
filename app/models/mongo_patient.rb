# Object representing core patient information and demographic data.
class MongoPatient
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Userstamp
  include Mongoid::History::Trackable

  store_in collection: 'patients'

  # The following are concerns, or groupings of domain-related methods
  # This blog post is a good intro: https://vaidehijoshi.github.io/blog/2015/10/13/stop-worrying-and-start-being-concerned-activesupport-concerns/
  extend Enumerize

  # Relationships
  has_and_belongs_to_many :users, inverse_of: :patients
  belongs_to :clinic
  embeds_one :fulfillment, as: :can_fulfill
  embeds_many :calls, as: :can_call
  embeds_many :external_pledges, as: :can_pledge
  embeds_many :practical_supports, as: :can_support
  embeds_many :notes, class_name: 'Note'
  belongs_to :pledge_generated_by, class_name: 'User', inverse_of: nil
  belongs_to :pledge_sent_by, class_name: 'User', inverse_of: nil
  belongs_to :last_edited_by, class_name: 'User', inverse_of: nil

  # Fields
  # Searchable info
  field :name, type: String # strip
  field :primary_phone, type: String
  field :other_contact, type: String
  field :other_phone, type: String
  field :other_contact_relationship, type: String
  field :identifier, type: String

  # Contact-related info
  field :voicemail_preference
  enumerize :voicemail_preference, in: [:not_specified, :no, :yes], default: :not_specified

  field :line
  enumerize :line, in: LINES, default: LINES[0] # See config/initializers/env_vars.rb

  field :language, type: String
  field :initial_call_date, type: Date
  field :urgent_flag, type: Boolean
  field :last_menstrual_period_weeks, type: Integer
  field :last_menstrual_period_days, type: Integer

  # Program analysis related or NAF eligibility related info
  field :age, type: Integer
  field :city, type: String
  field :state, type: String
  field :county, type: String
  field :race_ethnicity, type: String
  field :employment_status, type: String
  field :household_size_children, type: Integer
  field :household_size_adults, type: Integer
  field :insurance, type: String
  field :income, type: String
  field :special_circumstances, type: Array, default: []
  field :referred_by, type: String
  field :referred_to_clinic, type: Boolean
  field :completed_ultrasound, type: Boolean

  # Status and pledge related fields
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
  index({ primary_phone: 1 }, unique: true)
  index(other_contact_phone: 1)
  index(name: 1)
  index(other_contact: 1)
  index(urgent_flag: 1)
  index(line: 1)
  index(identifier: 1)

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'
end
# PORTED
