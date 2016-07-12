class Patient
  include Auditable
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


  # Methods
<<<<<<< HEAD


  def self.search(name_or_phone_str) # TODO: optimize
    name_matches = Patient.where name: name_or_phone_str
    primary_matches = Patient.where primary_phone: name_or_phone_str
    secondary_matches = Patient.where secondary_phone: name_or_phone_str
    (name_matches | primary_matches | secondary_matches)

=======
>>>>>>> 8c7a42b6378613a3d494de52ad5667eff2ea1246
  def self.search(name_or_phone_str) # Optimized Search the is case insensitive and phone number formatting agnostic
    clean_phone = name_or_phone_str.gsub(/\D/, '')
    formatted_phone = "#{clean_phone[0..2]}-#{clean_phone[3..5]}-#{clean_phone[6..10]}"
    begin
      name_matches = Patient.where name: /#{Regexp.escape(name_or_phone_str)}/i
      secondary_name_matches = Patient.where other_contact: /#{Regexp.escape(name_or_phone_str)}/i
      primary_matches = Patient.where primary_phone: formatted_phone
      secondary_matches = Patient.where other_phone: formatted_phone
      (name_matches | secondary_name_matches | primary_matches | secondary_matches)
    end

  end
end
