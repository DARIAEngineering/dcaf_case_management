# Object representing money from organizations associated with a patient.
class Pledge
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

  # Relationships
  embedded_in :patient

  # Fields
  field :pledge_type, type: String # soft/patient/naf/other/final_dcaf
  field :amount, type: Integer
  field :other_pledge_identifier, type: String
  field :sent, type: DateTime # validate presence when type is final
  field :sent_by, type: String # validate presence when type is final
  field :paid, type: Boolean # validate presence when type is final
  field :paid_date, type: DateTime # validate presence when type is final

  # Validations
  validates :created_by, :pledge_type, presence: true

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'
end
