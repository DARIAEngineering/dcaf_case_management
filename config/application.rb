require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Daria
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Customs
    # Custom exceptions pages
    config.exceptions_app = self.routes

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    config.time_zone = 'Eastern Time (US & Canada)' # this is bad. Should hardset to UTC and find some way to programmatically determine timezone based on user.

    # temporary, can be removed in separate release once data migration for encrypted data is complete
    config.active_record.encryption.support_unencrypted_data = true
    # the first key in the list is the active key to perform encryptions, the rest of the list is decryption keys (to support key rotation)
    config.active_record.encryption.primary_key = [ENV.fetch("ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY", "default_primary_key")]
    config.active_record.encryption.key_derivation_salt = ENV.fetch("ACTIVE_RECORD_KEY_DERIVATION_SALT", "default_salt")
    config.active_record.encryption.deterministic_key = [ENV.fetch("ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY", "default_deterministic_key")]
  end
end
