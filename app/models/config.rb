class Config
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Userstamp
  include Mongoid::Enum
  include Mongoid::History::Trackable

  # Fields
  enum :config_key, [:insurance, :external_pledge_source]
  field :config_value, type: Hash

  # Indices
  index({ _config_key: 1 }, unique: true)

  # Validations
  validates :_config_key, uniqueness: true, presence: true

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'

  # Methods
  def options
    config_value[:options]
  end
end
