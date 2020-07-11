# A case manager's log of their interactions with a patient.
# A patient embeds many notes.
class MongoNote
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

  store_in collection: 'notes'

  # Relationships
  embedded_in :patient, class_name: 'Patient'

  # Fields
  field :full_text, type: String

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'
end
