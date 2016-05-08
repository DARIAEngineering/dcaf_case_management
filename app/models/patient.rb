class Patient
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

  # Relationships
  has_many :pregnancies

  field :name, type: String # strip
  field :primary_phone, type: String
  field :secondary_person, type: String
  field :secondary_phone, type: String

  # Validations
  validates :name,
            :primary_phone,
            :created_by,
            presence: true
  validates :primary_phone, :secondary_phone, length: { maximum: 12 }

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
  def self.search(name_or_phone_str) # TODO: optimize
    name_matches = Patient.where name: name_or_phone_str
    primary_matches = Patient.where primary_phone: name_or_phone_str
    secondary_matches = Patient.where secondary_phone: name_or_phone_str
    (name_matches | primary_matches | secondary_matches)
  end
end
