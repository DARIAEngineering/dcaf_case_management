class Patient
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

  before_validation :clean_fields

  # Relationships
  has_and_belongs_to_many :users, inverse_of: :patients
  embeds_one :pregnancy
  embeds_many :calls
  embeds_many :pledges
  embeds_many :notes

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
  def primary_phone_display
    return nil unless primary_phone.present?
    "#{primary_phone[0..2]}-#{primary_phone[3..5]}-#{primary_phone[6..9]}"
  end

  def other_phone_display
    return nil unless other_phone.present?
    "#{other_phone[0..2]}-#{other_phone[3..5]}-#{other_phone[6..9]}"
  end

  # Search-related stuff
  class << self
    # Case insensitive and phone number format agnostic!
    def search(name_or_phone_str)
      name_regexp = /#{Regexp.escape(name_or_phone_str)}/i
      clean_phone = name_or_phone_str.gsub(/\D/, '')
      phone_regexp = /#{Regexp.escape(clean_phone)}/

      all_matching_names = find_name_matches name_regexp
      all_matching_phones = find_phone_matches phone_regexp

      (all_matching_names | all_matching_phones)
    end

    private

    def find_name_matches(name_regexp)
      if nonempty_regexp? name_regexp
        primary_names = Patient.where name: name_regexp
        other_names = Patient.where other_contact: name_regexp
        return (primary_names | other_names)
      end
      []
    end

    def find_phone_matches(phone_regexp)
      if nonempty_regexp? phone_regexp
        primary_phones = Patient.where primary_phone: phone_regexp
        other_phones = Patient.where other_phone: phone_regexp
        return (primary_phones | other_phones)
      end
      []
    end

    def nonempty_regexp?(regexp)
      # Escaped regexes are always present, so check presence
      # after stripping out standard stuff
      # (opening stuff to semicolon, closing parenthesis)
      regexp.to_s.gsub(/^.*:/, '').chop.present?
    end
  end

  private

  def clean_fields
    primary_phone.gsub!(/\D/, '') if primary_phone
    other_phone.gsub!(/\D/, '') if other_phone
    name.strip! if name
    other_contact.strip! if other_contact
    other_contact_relationship.strip! if other_contact_relationship
  end
end
