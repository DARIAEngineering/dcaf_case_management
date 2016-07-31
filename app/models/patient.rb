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
  # Search-related stuff
  class << self
    # Case insensitive and phone number format agnostic!
    def search(name_or_phone_str)
      name_regexp = /#{Regexp.escape(name_or_phone_str)}/i
      clean_phone = name_or_phone_str.gsub(/\D/, '')
      phone_regexp = /#{Regexp.escape(clean_phone)}/

      puts name_regexp
      puts phone_regexp
      puts name_regexp.present?
      puts phone_regexp.present?

      all_matching_names = find_name_matches name_regexp
      all_matching_phones = find_phone_matches phone_regexp

      (all_matching_names | all_matching_phones)

      # # name_match # Susan Sher
      # # secondary_name_match # 0
      # # primary_match # 4
      # # secondary_match # 2
    end

    private

    def find_name_matches(name_regexp)
      if name_regexp.present?
        primary_names = Patient.where name: name_regexp
        other_names = Patient.where other_contact: name_regexp
        return (primary_names | other_names)
      end
      []
    end

    def find_phone_matches(phone_regexp)
      if phone_regexp.present?
        primary_phones = Patient.where primary_phone: phone_regexp
        other_phones = Patient.where other_phone: phone_regexp
        return (primary_phones | other_phones)
      end
      []
    end
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
