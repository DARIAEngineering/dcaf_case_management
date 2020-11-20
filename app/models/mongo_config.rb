# Class so that funds can set their own dropdown lists of things
class MongoConfig
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Userstamp
  include Mongoid::History::Trackable
  extend Enumerize

  store_in collection: 'configs'

  # Comma separated configs
  CONFIG_FIELDS = [
    :insurance, :external_pledge_source, :pledge_limit_help_text,
    :language, :resources_url, :practical_support_guidance_url, :fax_service, :referred_by,
    :practical_support, :hide_practical_support, :start_of_week, :budget_bar_max
  ].freeze

  # Fields
  enumerize :config_key, in: CONFIG_FIELDS
  field :config_value, type: Hash, default: { options: [] }

  # Indices
  index({ config_key: 1 }, unique: true)

  # Validations
  validates :config_key, uniqueness: true, presence: true

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'
end
