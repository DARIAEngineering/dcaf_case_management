# Object representing money from organizations that aren't the fund or NAF.
# For primary fund pledges or NAF pledges, see the patient model.
class MongoExternalPledge
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

  store_in collection: 'external_pledges'

  # Relationships
  embedded_in :can_pledge, polymorphic: true

  # Fields
  field :source, type: String # Name of outside organization or fund
  field :amount, type: Integer
  field :active, type: Boolean, default: true

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'
end
