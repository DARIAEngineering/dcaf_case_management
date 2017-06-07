require File.expand_path('../boot', __FILE__)

# We require individual items instead of rails/all because 
# we don't need ActiveRecord, and ActiveRecord freaks out
# if there's no connection pool. -CF
# require 'rails/all'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DcafCaseManagement
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)' # this is bad. Should hardset to UTC and find some way to programmatically determine timezone based on user.

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.generators do |g|
      g.orm :mongoid
    end

    # Throttling protection
    config.middleware.use Rack::Attack

    # Load external pledges
    config.external_pledges = config_for(:external_pledges)
    # Load insurance options
    config.insurances = config_for(:insurance)

    # Raise errors in transactional callbacks. We have this turned off because
    # we are using Mongoid instead of Rails' built in ActiveRecord. -CF
    # Do not swallow errors in after_commit/after_rollback callbacks.
    # config.active_record.raise_in_transactional_callbacks = true
  end
end
