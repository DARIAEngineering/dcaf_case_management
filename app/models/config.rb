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
    :language, :resources_url, :fax_service, :referred_by,
    :practical_support, :show_practical_support, :start_of_week
  ].freeze

  # Define overrides for particular config fields.
  # Useful if there is no `_options` method.
  HELP_TEXT_OVERRIDES = {
    resources_url: 'A link to a Google Drive folder with CM resources. ' \
                   'Ex: https://drive.google.com/drive/my-resource-dir',
    fax_service: 'A link to your fax service. ex: https://www.efax.com',
    start_of_week: "The start day of your budget week, if it doesn't start on Monday. ex: Sunday.",
    show_practical_support: 'Toggle the visibility of practical support information. Enter "Yes" to show or "No" to hide. Note: This will not remove any existing data.'
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

  def self.start_day
    start = Config.find_or_create_by(config_key: 'start_of_week').options.try :last
    start ||= "monday"
    start.downcase.to_sym
  end

  def self.show_practical_support?
    show_value = Config.find_or_create_by(config_key: 'show_practical_support').options.try :last
    show_value ||= :yes
    show_value.downcase.strip.to_sym != :no
  end
end
