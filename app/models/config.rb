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

  # which fields are URLs (run special validation only on those)

  # symbols are required here because functions are not objects in rails :)
  CLEAN_PRE_VALIDATION = {
    start_of_week: :fix_capitalization,
    hide_practical_support: :fix_capitalization,
  }

  VALIDATIONS = {
    start_of_week: :validate_start_of_week,

    hide_practical_support: :validate_hide_practical_support,

    budget_bar_max: :validate_number,
    
    resources_url: :validate_url,
    fax_service: :validate_url,
    practical_support_guidance_url: :validate_url
  }

  before_validation :clean_config_value

  validates :config_key, uniqueness: true, presence: true
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

  private
    ### Generic Functions

    def clean_config_value
      # do nothing if empty
      return if config_key.nil? || options.last.nil?

      cleaner = CLEAN_PRE_VALIDATION[config_key.to_sym]

      # no clean function, return
      return if cleaner.nil?

      # we need to use `method` because `cleaner` is a symbol... this converts
      # the symbol into a Method object, which we can then `call`...
      # See https://ruby-doc.org/core/Object.html#method-i-method
      method(cleaner).call
    end

    # parent function. will handle errors; child validators should return true
    # if value is valid for key, and false otherwise.
    def validate_config
      # don't try to validate if no key or no value
      return if config_key.nil? || options.last.nil?

      validator = VALIDATIONS[config_key.to_sym]

      # no validation for this field, ignore
      return if validator.nil?

      # run the validator and get a boolean, exit if true
      # (see comment above in `clean_config_value` for an explainer)
      return if method(validator).call

      errors.add(:invalid_value_for, "#{config_key.humanize(capitalize: false)}: '#{options.last}'")
    end

    # generic validator for words (so we have standardized capitalization)
    def fix_capitalization
      config_value['options'] = [options.last.capitalize]
    end

    # generic validator for numerics
    def validate_number
      return options.last =~ /\A\d+\z/
    end


    ### URL fields

    def validate_url
      maybe_url = options.last
      return if maybe_url.blank?
      
      url = UriService.new(maybe_url).uri

      # uriservice returns nil if there's a problem.
      return false if !url

      config_value['options'] = [url]
      return true
    end

    ### Start of Week

    START_OF_WEEK = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
      "Monthly"
    ].freeze

    def validate_start_of_week
      return START_OF_WEEK.include?(options.last.capitalize)
    end

    ### Practical support

    def validate_hide_practical_support
      # allow yes or no, to be nice (technically only yes is considered)
      return options.last =~ /\A(yes|no)\z/i
    end
end
