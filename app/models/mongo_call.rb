# Object representing a case manager dialing a patient.
class MongoCall
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

  store_in collection: 'calls'

  # Relationships
  embedded_in :can_call, polymorphic: true

  # Fields
  field :status, type: String


  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'
end
# PORTED
