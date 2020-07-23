class MongoPracticalSupport
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

  store_in collection: 'practical_supports'

  # Relationships
  embedded_in :can_support, polymorphic: true

  # Fields
  field :support_type, type: String
  field :confirmed, type: Mongoid::Boolean
  field :source, type: String # Name of outside organization or fund

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'
end
# Ported
