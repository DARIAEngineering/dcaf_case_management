class Fulfillment
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

  # Relationships
  embedded_in :patient

  field :fulfilled, type: Boolean
  field :procedure_date, type: Date
  field :gestation_at_procedure, type: String
  field :procedure_cost, type: Integer
  field :check_number, type: Integer
  field :date_of_check, type: Date

  # Validations
  validates :created_by,
            presence: true

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'
end
