require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Daria
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)' # this is bad. Should hardset to UTC and find some way to programmatically determine timezone based on user.

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.generators do |g|
      g.orm :active_record
    end

    # Throttling protection
    config.middleware.use Rack::Attack

    # Force JSON cookies for security reasons
    config.action_dispatch.cookies_serializer = :json

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Custom exceptions pages
    config.exceptions_app = self.routes

    # temporary, can be removed in separate release once data migration for encrypted data is complete
    config.active_record.encryption.support_unencrypted_data = true
    # the first key in the list is the active key to perform encryptions, the rest of the list is decryption keys (to support key rotation)
    config.active_record.encryption.primary_key = [ENV.fetch("ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY", "default_primary_key")]
    config.active_record.encryption.key_derivation_salt = ENV.fetch("ACTIVE_RECORD_KEY_DERIVATION_SALT", "default_salt")
    config.active_record.encryption.deterministic_key = [ENV.fetch("ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY", "default_deterministic_key")]
  end
end
