require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
# require 'minitest/autorun'
require 'capybara/rails'
require 'capybara-screenshot/minitest'
require 'omniauth_helper'
require 'integration_helper'
# require 'rack/test'

# CI only
if ENV['CIRCLECI']
  # Use knapsack to split up tests on CI nodes
  # To rerack the test divider, run:
  # KNAPSACK_GENERATE_REPORT=true bundle exec rake test test:system
  require 'knapsack'
  knapsack_adapter = Knapsack::Adapters::MinitestAdapter.bind
  knapsack_adapter.set_test_helper_path(__FILE__)

  # Activate codecov reporter for test coverage reports
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov

  # Save screenshots if system tests fail
  Capybara.save_path = Rails.root.join('tmp', 'capybara')
end

DatabaseCleaner.clean_with :truncation

# Convenience methods around config creation, and database cleaning
class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  before do
    Bullet.start_request
    DatabaseCleaner.start
  end
  after do
    Bullet.perform_out_of_channel_notifications if Bullet.notification?
    Bullet.end_request
    DatabaseCleaner.clean
  end

  def create_insurance_config
    insurance_options = ['DC Medicaid', 'Other state Medicaid']
    create :config, config_key: 'insurance',
                    config_value: { options: insurance_options }
  end

  def create_practical_support_config
    practical_support_options = ['Metallica Tickets', 'Clothing']
    create :config, config_key: 'practical_support',
                    config_value: { options: practical_support_options }
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

  def create_voicemail_config
      vm_options = ['Text Message Only', 'Use Codename', 'Only During Business Hours']
      create :config, config_key: 'voicemail',
                      config_value: { options: vm_options }
  end

  def create_referred_by_config
    referred_by_options = ['Metal band']
    create :config, config_key: 'referred_by',
                    config_value: { options: referred_by_options }
  end

  def create_fax_service_config
    create :config, config_key: 'fax_service',
                    config_value: { options: ['http://www.yolofax.com'] }
  end

  def with_versioning(user = nil)
    was_enabled = PaperTrail.enabled?
    was_enabled_for_request = PaperTrail.request.enabled?
    PaperTrail.enabled = true
    PaperTrail.request.enabled = true
    begin
      if user
        PaperTrail.request(whodunnit: user.id) do
          yield
        end
      else
        yield
      end
    ensure
      PaperTrail.enabled = was_enabled
      PaperTrail.request.enabled = was_enabled_for_request
    end
  end
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
end
