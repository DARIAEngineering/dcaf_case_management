# Object representing money from outside organizations.
class Pledge
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

  # Relationships
  embedded_in :patient

  default_scope :active, -> { where active: true }

  # Fields
  field :source, type: String # Name of outside organization or fund
  field :amount, type: Integer
  field :active, type: Boolean, default: true

  # Validations
  validates :created_by, :source, presence: true

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'
end
