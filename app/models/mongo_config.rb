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
    :language, :resources_url, :practical_support_guidance_url, :fax_service, :referred_by,
    :practical_support, :hide_practical_support, :start_of_week, :budget_bar_max,
    :voicemail
  ].freeze

  # Define overrides for particular config fields.
  # Useful if there is no `_options` method.
  HELP_TEXT_OVERRIDES = {
    resources_url: 'A link to a Google Drive folder with CM resources. ' \
                   'Ex: https://drive.google.com/drive/my-resource-dir',
    practical_support_guidance_url: 'A link to a Google Drive folder with Practical Support resources. ' \
                   'Ex: https://drive.google.com/drive/my-practical_support',
    fax_service: 'A link to your fax service. ex: https://www.efax.com',
    start_of_week: "How to render your budget bar. Default is weekly starting on Monday. Enter \"Sunday\" for weekly budget starting on Sunday, or \"Monthly\" for a calendar month based budget.",
    budget_bar_max: "The maximum for the budget bar. Defaults to 1000 if not set. Enter as a number with no dollar sign or commas.",
    hide_practical_support: 'Enter "yes" to hide the Practical Support panel on patient pages. This will not remove any existing data.'
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

  def self.budget_bar_max
    budget_max = Config.find_or_create_by(config_key: 'budget_bar_max').options.try :last
    budget_max ||= 1_000
    budget_max.to_i
  end

  def self.hide_practical_support?
    Config.find_or_create_by(config_key: 'hide_practical_support').options.try(:last).to_s =~ /yes/i ? true : false
  end

  def self.start_day
    start = Config.find_or_create_by(config_key: 'start_of_week').options.try :last
    start ||= "monday"
    start.downcase.to_sym
  end
end
