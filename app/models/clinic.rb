# Object representing a clinic that a patient is going to.
class Clinic
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

  # Relationships
  has_many :patients

  # Fields
  field :name, type: String
  field :street_address, type: String
  field :city, type: String
  field :state, type: String
  field :zip, type: String
  field :phone, type: String
  field :fax, type: String
  field :active, type: Boolean, default: true
  field :accepts_naf, type: Boolean, default: false
  field :gestational_limit, type: Integer
  # costs_5wks, costs_6wks, ..., costs_30wks
  (5..30).each { |i| field "costs_#{i}wks".to_sym, type: Integer }

  # Validations
  validates :name, :street_address, :city, :state, :zip, presence: true
  validates :name, uniqueness: true

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'

  # Methods
  def display_location
    return nil if city.blank? || state.blank?
    "#{city}, #{state}"
  end
end
