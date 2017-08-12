require 'simplecov'
SimpleCov.start 'rails'

require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
# require 'minitest/reporters'
require 'minitest/autorun'
# require 'capybara/rails'
require 'capybara/poltergeist'
# require 'capybara-screenshot/minitest'
require 'omniauth_helper'
require 'rack/test'
# require 'integration_system_test_helpers'
# Minitest::Reporters.use! Minitest::Reporters::ProgressReporter

# Capybara.register_driver :poltergeist do |app|
  # Capybara::Poltergeist::Driver.new(app, js_errors: false)
# end

DatabaseCleaner.clean_with :truncation

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  before { DatabaseCleaner.start }
  after  { DatabaseCleaner.clean }
end

# Save screenshots if integration tests fail
Capybara.save_path = "#{ENV.fetch('CIRCLE_ARTIFACTS', Rails.root.join('tmp/capybara'))}" if ENV['CIRCLE_ARTIFACTS']

class ActionDispatch::IntegrationTest
  # include IntegrationSystemTestHelpers

  def sign_in(user)
    post user_session_path \
      'user[email]' => user.email,
      'user[password]' => user.password
  end

  def choose_line(line)
    post lines_path, params: { line: line.to_s }
  end
end

class ActionController::TestCase
  # include Devise::TestHelpers
  include Devise::Test::ControllerHelpers
end
