# Object representing a clinic that a fund works with.
# NOTE: NOT CURRENTLY FULLY IMPLEMENTED. DO NOT USE. USE Patient#clinic_name instead.
class Clinic
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp
  include ClinicsHelper

  # Fields
  field :name, type: String
  field :address, type: String
  field :city, type: String
  field :state, type: String
  field :zip, type: String
  field :active, type: Boolean, default: true

  # Validations
  validates :name, :address, :city, :state, :zip, presence: true

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'
end
