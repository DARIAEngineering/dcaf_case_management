class Config
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Userstamp
  include Mongoid::History::Trackable

  # Fields
  field :config_key, type: String
  field :config_json, type: Hash

  # Indices
  index({ config_key: 1 }, unique: true)

  # Validations
  validates_uniqueness_of :config_key

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'
end
