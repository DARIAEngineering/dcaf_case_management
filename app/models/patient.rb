class Patient
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

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
  validates :primary_phone, :other_phone, length: { maximum: 12 }

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
  def self.search(name_or_phone_str) # Optimized Search the is case insensitive and phone number formatting agnostic
    name_regexp = /#{Regexp.escape(name_or_phone_str)}/i
    phone_regexp = create_phone_regexp name_or_phone_str
    begin
      name_match = Patient.where name: name_regexp
      secondary_name_match = Patient.where other_contact: name_regexp
      primary_match = Patient.where primary_phone: phone_regexp
      secondary_match = Patient.where other_phone: phone_regexp
      (name_match | secondary_name_match | primary_match | secondary_match)
    end
  end

  private

  def create_phone_regexp(name_or_phone_str)
    clean_phone = name_or_phone_str.gsub(/\D/, '')
    /#{clean_phone[0..2]}-#{clean_phone[3..5]}-#{clean_phone[6..10]}/i
  end
end
