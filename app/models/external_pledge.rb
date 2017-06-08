# Object representing money from organizations that aren't the fund or NAF.
# For primary fund pledges or NAF pledges, see the patient model.
class ExternalPledge
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

  # Relationships
  embedded_in :patient

  default_scope -> { where(active: true) }
  scope :active, -> { where(active: true) }

  # Fields
  field :source, type: String # Name of outside organization or fund
  field :amount, type: Integer
  field :active, type: Boolean, default: true

  # Validations
  validates :created_by_id, :source, :amount, presence: true
  validates :source, uniqueness: { scope: :active }

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'
end
