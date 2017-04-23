# Object representing core patient information and demographic data.
class Patient
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Enum
  include Mongoid::Userstamp
  include Mongoid::History::Trackable
  include StatusHelper

  # The following are concerns, or groupings of domain-related methods
  # This blog post is a good intro: https://vaidehijoshi.github.io/blog/2015/10/13/stop-worrying-and-start-being-concerned-activesupport-concerns/
  include Urgency
  include Callable
  include Notetakeable
  include Searchable
  include AttributeDisplayable
  include HistoryTrackable

  LINES.each do |line|
    scope line.downcase.to_sym, -> { where(:_line.in => [line]) }
  end

  before_validation :clean_fields

  # Relationships
  has_and_belongs_to_many :users, inverse_of: :patients
  belongs_to :clinic
  embeds_one :pregnancy
  embeds_one :fulfillment
  embeds_many :calls
  embeds_many :external_pledges
  embeds_many :notes

  # Enable mass posting in forms
  accepts_nested_attributes_for :pregnancy
  accepts_nested_attributes_for :fulfillment

  # Fields
  field :name, type: String # strip
  field :primary_phone, type: String
  field :other_contact, type: String
  field :other_phone, type: String
  field :other_contact_relationship, type: String
  field :identifier, type: String

  enum :voicemail_preference, [:not_specified, :no, :yes]
  enum :line, [:DC, :MD, :VA] # See config/initializers/lines.rb. TODO: Env var.
  field :spanish, type: Boolean

  field :age, type: Integer
  field :city, type: String
  field :state, type: String
  field :zip, type: String
  field :county, type: String
  field :race_ethnicity, type: String
  field :employment_status, type: String
  field :household_size_children, type: Integer
  field :household_size_adults, type: Integer
  field :insurance, type: String
  field :income, type: String
  field :referred_by, type: String
  field :appointment_date, type: Date
  field :initial_call_date, type: Date

  field :urgent_flag, type: Boolean
  field :special_circumstances, type: Array, default: []

  # Indices
  index({ primary_phone: 1 }, unique: true)
  index(other_contact_phone: 1)
  index(name: 1)
  index(other_contact: 1)
  index(urgent_flag: 1)
  index(_line: 1)
  index(identifier: 1)

  # Validations
  validates :name,
            :primary_phone,
            :initial_call_date,
            :created_by_id,
            :line,
            presence: true
  validates :primary_phone, format: /\d{10}/, length: { is: 10 }, uniqueness: true
  validates :other_phone, format: /\d{10}/,
                          length: { is: 10 },
                          allow_blank: true
  validates :appointment_date, format: /\A\d{4}-\d{1,2}-\d{1,2}\z/,
                               allow_blank: true

  validate :confirm_appointment_after_initial_call

  validates_associated :pregnancy
  validates_associated :fulfillment
  before_save :save_identifier

  # some validation of presence of at least one pregnancy
  # some validation of only one active pregnancy at a time

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'

  # Methods
  def self.pledged_status_summary(num_days = 7)
    # return pledge totals for patients with appts in the next num_days
    # TODO move to Pledge class, when implemented?
    outstanding_pledges = 0
    sent_total = 0
    Patient.where(:appointment_date.lte => Date.today + num_days).each do |patient|
      if patient.pregnancy.pledge_sent
        sent_total += (patient.pregnancy.dcaf_soft_pledge || 0)
      else
        outstanding_pledges += (patient.pregnancy.dcaf_soft_pledge || 0)
      end
    end
    { pledged: outstanding_pledges, sent: sent_total }
  end

  def save_identifier
    self.identifier = "#{line[0]}#{primary_phone[-5]}-#{primary_phone[-4..-1]}"
  end

  private

  def confirm_appointment_after_initial_call
    if appointment_date.present? && initial_call_date > appointment_date
      errors.add(:appointment_date, 'must be after date of initial call')
    end
  end

  def clean_fields
    primary_phone.gsub!(/\D/, '') if primary_phone
    other_phone.gsub!(/\D/, '') if other_phone
    name.strip! if name
    other_contact.strip! if other_contact
    other_contact_relationship.strip! if other_contact_relationship
  end
end
