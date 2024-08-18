# Class so that funds can set their own dropdown lists of things
class Config < ApplicationRecord
  acts_as_tenant :fund

  # Concerns
  include PaperTrailable

  # Define overrides for particular config fields help text.
  HELP_TEXT_OVERRIDES = {
    resources_url: 'A link to a Google Drive folder with CM resources. ' \
                   'Ex: https://drive.google.com/drive/my-resource-dir',
    practical_support_guidance_url: 'A link to a Google Drive folder with Practical Support resources. ' \
                   'Ex: https://drive.google.com/drive/my-practical_support',
    fax_service: 'A link to your fax service. ex: https://www.efax.com',
    start_of_week: "How to render your budget bar. Default is weekly starting on Monday. Enter \"Sunday\" for weekly budget starting on Sunday, or \"Monthly\" for a calendar month based budget.",
    budget_bar_max: "The maximum for the budget bar. Defaults to 1000 if not set. Enter as a number with no dollar sign or commas.",
    hide_practical_support: 'Enter "yes" to hide the Practical Support panel on patient pages. This will not remove any existing data.',
    days_to_keep_fulfilled_patients: "Number of days (after initial entry) to keep identifying information for a patient whose pledge has been fulfilled and marked audited. Defaults to 90 days (3 months).",
    days_to_keep_all_patients: "Number of days (after initial entry) to keep identifying information for any patient, regardless of pledge fulfillment. Defaults to 365 days (1 year).",
    shared_reset: "Number of idle days until a patient is removed from the shared list. Defaults to 6 days, maximum 6 weeks.",
    hide_budget_bar: 'Enter "yes" to hide the budget bar display.',
    aggregate_statistics: 'Enter "yes" to show aggregate statistics on the budget bar.',
    hide_standard_dropdown_values: 'Enter "yes" to hide standard dropdown values. Only custom options (specified on this page) will be used.',
    time_zone: "Time zone to use for displaying dates. Default is Eastern. Valid options are Eastern, Central, Mountain, Pacific, Alaska, Hawaii, Arizona, Indiana (East), or Puerto Rico.",
    procedure_type: "Any kind of distinction in procedure your fund would like to track. Field hides if no options " \
                    "are added here. Please separate with commas.",
    show_patient_identifier: 'Enter "yes" to show the patient\' Daria Identifier on the patient information tab.',
    display_practical_support_attachment_url: 'CAUTION: Whether or not to allow people to enter attachment URLs for practical support entries; for example, a link to a file in Google Drive. Please ensure that any system storing these is properly secured by your fund!',
    display_practical_support_waiver: 'Whether or not to display a checkbox for whether or not a patient has signed a practical support waiver. For funds that use waivers for practical support recipients.'
  }.freeze

  # Whether a config should show a current options dropdown to the right
  # Must have a `_options` method implemented
  SHOW_CURRENT_OPTIONS = [
    :county,
    :external_pledge_source,
    :insurance,
    :language,
    :pledge_limit_help_text,
    :practical_support,
    :procedure_type,
    :referred_by,
    :voicemail,
  ]

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
    days_to_keep_fulfilled_patients: 13,
    days_to_keep_all_patients: 14,
    shared_reset: 15,
    hide_budget_bar: 16,
    aggregate_statistics: 17,
    hide_standard_dropdown_values: 18,
    county: 19,
    time_zone: 20,
    procedure_type: 21,
    show_patient_identifier: 22,
    display_practical_support_attachment_url: 23,
    display_practical_support_waiver: 24,
  }

  # which fields are URLs (run special validation only on those)

  # symbols are required here because functions are not objects in rails :)
  CLEAN_PRE_VALIDATION = {
    start_of_week: [:fix_capitalization],
    hide_practical_support: [:fix_capitalization],
    language: [:fix_capitalization],
    county: [:fix_capitalization],
    time_zone: [:titleize_capitalization]
  }.freeze

  VALIDATIONS = {
    insurance:
      [:validate_length],
    external_pledge_source:
      [:validate_length],
    pledge_limit_help_text:
      [:validate_length],
    practical_support:
      [:validate_length],
    referred_by:
      [:validate_length],
    voicemail:
      [:validate_length],
    county:
      [:validate_length],
    procedure_type:
      [:validate_length],

    start_of_week:
      [:validate_singleton, :validate_start_of_week],
    time_zone: 
      [:validate_singleton, :validate_time_zone],

    hide_practical_support:
      [:validate_singleton, :validate_yes_or_no],
    display_practical_support_attachment_url:
      [:validate_singleton, :validate_yes_or_no],
    display_practical_support_waiver:
      [:validate_singleton, :validate_yes_or_no],

    budget_bar_max:
      [:validate_singleton, :validate_number],

    resources_url:
      [:validate_singleton, :validate_url],
    fax_service:
      [:validate_singleton, :validate_url],
    practical_support_guidance_url:
      [:validate_singleton, :validate_url],

    days_to_keep_fulfilled_patients:
      [:validate_singleton, :validate_patient_archive],
    days_to_keep_all_patients:
      [:validate_singleton, :validate_patient_archive],
    shared_reset:
      [:validate_singleton, :validate_shared_reset],

    hide_budget_bar:
      [:validate_singleton, :validate_yes_or_no],
    aggregate_statistics:
      [:validate_singleton, :validate_yes_or_no],
    hide_standard_dropdown_values:
      [:validate_singleton, :validate_yes_or_no],
    show_patient_id:
      [:validate_singleton, :validate_yes_or_no],
  }.freeze

  before_validation :clean_config_value

  validates :config_key, presence: true
  validates_uniqueness_to_tenant :config_key
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

  def self.config_to_bool(key)
    Config.find_or_create_by(config_key: key).options.try(:last).to_s =~ /yes/i ? true : false
  end

  def self.budget_bar_max
    budget_max = Config.find_or_create_by(config_key: 'budget_bar_max').options.try :last
    budget_max ||= 1_000
    budget_max.to_i
  end

  def self.hide_practical_support?
    config_to_bool('hide_practical_support')
  end

  def self.start_day
    start = Config.find_or_create_by(config_key: 'start_of_week').options.try :last
    start ||= "monday"
    start.downcase.to_sym
  end

  def self.time_zone
    tz = Config.find_or_create_by(config_key: 'time_zone').options.try :last
    tz ||= "Eastern"
    ActiveSupport::TimeZone.new(TIME_ZONE[tz])
  end

  def self.archive_fulfilled_patients
    archive_days = Config.find_or_create_by(config_key: 'days_to_keep_fulfilled_patients').options.try :last
    # default 3 months
    archive_days ||= 90
    archive_days.to_i
  end

  def self.archive_all_patients
    archive_days = Config.find_or_create_by(config_key: 'days_to_keep_all_patients').options.try :last
    # default 1 year
    archive_days ||= 365
    archive_days.to_i
  end

  def self.shared_reset
    shared_reset_days = Config.find_or_create_by(config_key: 'shared_reset').options.try :last
    # default 6 days
    shared_reset_days ||= 6
    shared_reset_days.to_i
  end

  def self.hide_budget_bar?
    config_to_bool('hide_budget_bar')
  end

  def self.show_aggregate_statistics?
    config_to_bool('aggregate_statistics')
  end

  def self.hide_standard_dropdown?
    config_to_bool('hide_standard_dropdown_values')
  end

  def self.show_patient_identifier?
    config_to_bool('show_patient_identifier')
  end

  def self.display_practical_support_attachment_url?
    config_to_bool('display_practical_support_attachment_url')
  end

  def self.display_practical_support_waiver?
    config_to_bool('display_practical_support_waiver')
  end

  private
    ### Generic Functions

    def clean_config_value
      # do nothing if empty
      return if config_key.nil? || options.last.nil?

      cleaners = CLEAN_PRE_VALIDATION[config_key.to_sym]

      # no clean function, return
      return if cleaners.blank?

      # we need to use `method` because `cleaner` is a symbol... this converts
      # the symbol into a Method object, which we can then `call`...
      # See https://ruby-doc.org/core/Object.html#method-i-method
      cleaners.each { |cleaner| method(cleaner).call }
    end

    # parent function. will handle errors; child validators should return true
    # if value is valid for key, and false otherwise.
    def validate_config
      # don't try to validate if no key or no value
      return if config_key.nil? || options.last.nil?

      validators = VALIDATIONS[config_key.to_sym]

      # no validation for this field, ignore
      return if validators.blank?

      # run the validators and get a boolean, exit if all are true
      # (see comment above in `clean_config_value` for an explainer)
      return if validators.all? { |validator| method(validator).call }

      errors.add(:invalid_value_for,
        "#{config_key.humanize(capitalize: false)}: #{options.join(', ')}")
    end

    # generic cleaner for words (so we have standardized capitalization)
    def fix_capitalization
      config_value['options'] = options.map(&:capitalize)
    end

    # similar to fix_capitalization but when we need titleized text (e.g. time zones)
    def titleize_capitalization
      config_value['options'] = options.map(&:titleize)
    end

    # generic validator for numerics
    def validate_number
      options.last =~ /\A\d+\z/
    end

    # validator for singletons (no lists allowed)
    def validate_singleton
      options.length == 1
    end

    ### URL fields

    def validate_url
      maybe_url = options.last
      return if maybe_url.blank?

      return false unless maybe_url.length <= 300

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
      START_OF_WEEK.include?(options.last.capitalize)
    end

    ### Time zone

    TIME_ZONE = {
      "Eastern": "Eastern Time (US & Canada)",
      "Central": "Central Time (US & Canada)",
      "Mountain": "Mountain Time (US & Canada)",
      "Pacific": "Pacific Time (US & Canada)",
      "Alaska": "Alaska",
      "Hawaii": "Hawaii",
      "Arizona": "Arizona",
      "Indiana (East)": "Indiana (East)",
      "Puerto Rico": "Puerto Rico"
    }.stringify_keys!

    def validate_time_zone
      TIME_ZONE.keys.include?(options.last.titleize)
    end

    ### Practical support

    def validate_yes_or_no
      # allow yes or no, to be nice (technically only yes is considered)
      options.last =~ /\A(yes|no)\z/i
    end

    ### Patient archive
    ARCHIVE_MIN_DAYS = 60   # 2 months
    ARCHIVE_MAX_DAYS = 550  # 1.5 years

    def validate_patient_archive
      validate_number && options.last.to_i.between?(ARCHIVE_MIN_DAYS, ARCHIVE_MAX_DAYS)
    end

    ### shared reset
    SHARED_MIN_DAYS = 2      # 2 days
    SHARED_MAX_DAYS = 7 * 6  # 6 weeks

    def validate_shared_reset
      validate_number && options.last.to_i.between?(SHARED_MIN_DAYS, SHARED_MAX_DAYS)
    end

    def validate_length
      total_length = 0
      options.each do |option|
        total_length += option.length
        return false if total_length > 4000
      end
      true
    end
end
