# Object representing a clinic that a patient is going to.
class MongoClinic
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

  store_in collection: 'clinics'

  # Relationships
  has_many :patients
  has_many :archived_patients

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
  field :accepts_medicaid, type: Boolean, default: false
  field :gestational_limit, type: Integer
  field :coordinates, type: Array
  # costs_5wks, costs_6wks, ..., costs_30wks
  (5..30).each { |i| field "costs_#{i}wks".to_sym, type: Integer }

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'
end
# PORTED
