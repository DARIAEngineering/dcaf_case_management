# Class so that funds can set their own dropdown lists of things
class Config < ApplicationRecord
  # Concerns
  include PaperTrailable

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

  enum config_key: {
    insurance: 0,
    external_pledge_source: 1,
    pledge_limit_help_text: 2,
    language: 3,
    resources_url: 4,
    practical_support_guidance_url: 5,
    fax_service: 6,
    referred_by: 7,
    practical_support: 8,
    hide_practical_support: 9,
    start_of_week: 10,
    budget_bar_max: 11,
    voicemail: 12,
  }


  VALIDATIONS = {
    start_of_week: :validate_start_of_week,

    # hide_practical_support: validate_hide_practical_support,

    # budget_bar_max: validate_number,
    
    resources_url: :validate_url,
    fax_service: :validate_url,
    practical_support_guidance_url: :validate_url
  }

  # Validations
  validates :config_key, uniqueness: true, presence: true

  # run `clean_url` before validating a url. this is checked based on validation
  # function. not the cleanest but prevents code duplication
  before_validation :clean_url, if: -> { VALIDATIONS[config_key.to_sym] == :validate_url }
  validate :validate_config

  # Methods
  def options
    config_value['options']
  end

  def help_text
    text = HELP_TEXT_OVERRIDES[config_key.to_sym]
    return text if text

    'Please separate with commas.'
  end

  def self.autosetup
    config_keys.keys.each do |field|
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


  ## private?


  # parent function. will handle errors; child validators should return true
  # if value is valid for key, and false otherwise.
  def validate_config
    val_f = method(VALIDATIONS[config_key.to_sym])

    logger.info("VALIDATE_CONFIG #{config_key}: #{config_value} func #{val_f}")

    # no validation for this field, ignore
    return if val_f.nil?

    # allow empty config
    return if options.last.nil?

    # run the validator and get a boolean
    return if val_f.()

    errors.add(:invalid_value_for, "#{config_key.humanize}: '#{options.last}'.")
  end

  START_OF_WEEK = [
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
    "sunday",
    "monthly"
  ]

  def validate_start_of_week
    return START_OF_WEEK.include?(options.last.downcase)
  end

  def validate_url
    url = options.last

    if url =~ /\A#{URI::regexp(['https'])}\z/
      return true
    end

    return false    
  end


  def clean_url
    url = options.last

    # don't try to clean empty url
    return if url.blank?

    # don't have to do anything, already https
    return if url.start_with? 'https://'

    # convert http or // to https://
    if url.start_with? /(http:)?\/\//
        url = url.sub /^(http:)?\/\//, 'https://'

    # convert no scheme to https:// (i.e. example.com -> https://example.com)
    elsif not url.start_with? '/'
        url = 'https://' + url
    end

    # set config back to what it was
    config_value['options'] = [url]
  end

end
