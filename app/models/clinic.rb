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
  field :street_address, type: String
  field :city, type: String
  field :state, type: String
  field :zip, type: String
  field :phone, type: String
  field :active, type: Boolean, default: true
  field :accepts_naf, type: Boolean, default: false
  field :gestational_limit, type: Integer
  field :costs_05wks, type: Integer
  field :costs_06wks, type: Integer
  field :costs_07wks, type: Integer
  field :costs_08wks, type: Integer
  field :costs_09wks, type: Integer
  field :costs_10wks, type: Integer
  field :costs_11wks, type: Integer
  field :costs_12wks, type: Integer
  field :costs_13wks, type: Integer
  field :costs_14wks, type: Integer
  field :costs_15wks, type: Integer
  field :costs_16wks, type: Integer
  field :costs_17wks, type: Integer
  field :costs_18wks, type: Integer
  field :costs_19wks, type: Integer
  field :costs_20wks, type: Integer
  field :costs_21wks, type: Integer
  field :costs_22wks, type: Integer
  field :costs_23wks, type: Integer
  field :costs_24wks, type: Integer
  field :costs_25wks, type: Integer
  field :costs_26wks, type: Integer
  field :costs_27wks, type: Integer
  field :costs_28wks, type: Integer
  field :costs_29wks, type: Integer
  field :costs_30wks, type: Integer

  # Validations
  validates :name, :street_address, :city, :state, :zip, presence: true

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'
end
