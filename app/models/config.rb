# Class so that funds can set their own dropdown lists of things
class Config
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Userstamp
  include Mongoid::History::Trackable
  extend Enumerize

  # Comma separated configs
  CONFIG_FIELDS = [
    :insurance, :external_pledge_source, :pledge_limit_help_text,
    :language, :resources_url, :referred_by
  ].freeze

  # Define overrides for particular config fields
  HELP_TEXT_OVERRIDES = {
    resources_url: 'A link to a Google Drive folder with CM resources. ' \
                   'Ex: https://drive.google.com/drive/my-resource-dir'
  }.freeze

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

  # Methods
  def options
    config_value[:options]
  end

  def help_text
    text = HELP_TEXT_OVERRIDES[config_key.to_sym]
    return text if text

    'Please separate with commas.'
  end

  def self.autosetup
    CONFIG_FIELDS.map(&:to_s).each do |field|
      if Config.where(config_key: field).count != 1
        Config.create config_key: field
      end
    end
  end
end
