# Object representing a clinic that a fund works with.
# NOTE: NOT CURRENTLY IMPLEMENTED. DO NOT USE. USE Patient#clinic_name instead.
class Clinic
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp
  include ClinicsHelper

  # Relationships
  embedded_in :patient

  # Fields
  field :name, type: String
  field :street_address_1, type: String
  field :street_address_2, type: String
  field :city, type: String
  field :state, type: String # TODO: enumeration?
  field :zip, type: String

  # Validations
  # TODO: Validate clinic options based on ENV['CLINICS']

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'
end
