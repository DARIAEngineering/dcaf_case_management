require 'simplecov'
SimpleCov.start 'rails'

require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/autorun'
require 'capybara/rails'
require 'capybara-screenshot/minitest'
require 'omniauth_helper'
require 'integration_helper'
require 'rack/test'

if ENV['CIRCLE_ARTIFACTS']
  # To rerack the test divider, run:
  # KNAPSACK_GENERATE_REPORT=true bundle exec rake test test:system
  require 'knapsack'
  knapsack_adapter = Knapsack::Adapters::MinitestAdapter.bind
  knapsack_adapter.set_test_helper_path(__FILE__)
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false)
end

DatabaseCleaner.clean_with :truncation

# Convenience methods around config creation, and database cleaning
class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  before { DatabaseCleaner.start }
  after  { DatabaseCleaner.clean }

  def create_insurance_config
    insurance_options = ['DC Medicaid', 'Other state Medicaid']
    create :config, config_key: 'insurance',
                    config_value: { options: insurance_options }
  end

  def create_external_pledge_source_config
    ext_pledge_options = ['Baltimore Abortion Fund',
                          'Tiller Fund (NNAF)',
                          'NYAAF (New York)']
    create :config, config_key: 'external_pledge_source',
                    config_value: { options: ext_pledge_options }
  end

  def create_language_config
    language_options = %w[Spanish French Korean]
    create :config, config_key: 'language',
                    config_value: { options: language_options }
  end
end

# Save screenshots if integration tests fail
if ENV['CIRCLE_ARTIFACTS']
  circle_path = ENV.fetch('CIRCLE_ARTIFACTS',
                          Rails.root.join('tmp', 'capybara'))
  Capybara.save_path = circle_path
end

# Used by controller tests
class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Capybara::Screenshot::MiniTestPlugin
  include IntegrationHelper
  include OmniauthMocker
  OmniAuth.config.test_mode = true

  before { Capybara.reset_sessions! }

  # for controllers
  def sign_in(user)
    post user_session_path \
      'user[email]' => user.email,
      'user[password]' => user.password
  end

  def choose_line(line)
    post lines_path, params: { line: line.to_s }
  end
end
