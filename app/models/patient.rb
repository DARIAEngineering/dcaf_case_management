class Patient
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

  before_validation :clean_phones, :clean_names

  # Relationships
  has_many :pregnancies

  # Fields
  field :name, type: String # strip
  field :primary_phone, type: String
  field :other_contact, type: String
  field :other_phone, type: String
  field :other_contact_relationship, type: String

  # Validations
  validates :name,
            :primary_phone,
            :created_by,
            presence: true
  # validates :primary_phone, :other_phone, length: { maximum: 10 }
  validates :primary_phone, format: /\d{10}/, length: { is: 10 }
  validates :other_phone, format: /\d{10}/, length: { is: 10 }, allow_blank: true

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
  # Case insensitive and phone number format agnostic!
  def self.search(name_or_phone_str)
    name_regexp = /#{Regexp.escape(name_or_phone_str)}/i
    clean_phone = name_or_phone_str.gsub(/\D/, '')
    phone_regexp = /#{Regexp.escape(clean_phone)}/i

    # this doesn't work yet
    name_match = Patient.where name: name_regexp
    secondary_name_match = Patient.where other_contact: name_regexp
    primary_match = Patient.where primary_phone: phone_regexp
    secondary_match = Patient.where other_phone: phone_regexp
    (name_match | secondary_name_match | primary_match | secondary_match)
  end

  private

  def clean_phones
    primary_phone.gsub!(/\D/, '') if primary_phone
    other_phone.gsub!(/\D/, '') if other_phone
  end

  def clean_names
    name.strip! if name
    other_contact.strip! if other_contact
  end
end
