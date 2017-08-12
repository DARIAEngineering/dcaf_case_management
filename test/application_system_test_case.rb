require "capybara/poltergeist"
require 'omniauth_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include IntegrationSystemTestHelpers
  include OmniauthMocker

  before { Capybara.reset_sessions! }
  OmniAuth.config.test_mode = true

  # Poltergeist
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, js_errors: false)
  end
  driven_by :poltergeist
end
