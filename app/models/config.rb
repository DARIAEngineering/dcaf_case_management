# Class so that funds can set their own dropdown lists of things
class Config
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Userstamp
  include Mongoid::History::Trackable
  extend Enumerize

  CONFIG_FIELDS = [:insurance, :external_pledge_source]

  # Fields
  enumerize :config_key, in: CONFIG_FIELDS
  field :config_value, type: Hash

  # Indices
  index({ config_key: 1 }, unique: true)

  # Validations
  validates :config_key, uniqueness: true, presence: true
  # validates :created_by_id, presence: true

  # History and auditing
  track_history on: fields.keys,# + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  # mongoid_userstamp user_model: 'User'

  # Methods
  def options
    config_value[:options]
  end
end
