# Object representing a clinic that a fund works with.
# NOTE: NOT CURRENTLY IMPLEMENTED. DO NOT USE. USE Patient#clinic_name instead.
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
  field :state, type: String # ennnnnnummmmerrrrattttttioonnn???????
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
