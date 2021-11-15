require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/autorun'
require 'capybara/rails'
require 'capybara-screenshot/minitest'
require 'omniauth_helper'
require 'integration_helper'
require 'rack/test'

# CI only
if ENV['CI']
  # Save screenshots if system tests fail
  Capybara.save_path = Rails.root.join('tmp', 'capybara')
end

# Convenience methods around config creation, and database cleaning
class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  before do
    Bullet.start_request
    setup_tenant
  end

  after do
    Bullet.perform_out_of_channel_notifications if Bullet.notification?
    Bullet.end_request
    teardown_tenant
  end

  parallelize(workers: :number_of_processors)

  def setup_tenant
    tenant = create :fund, name: 'DCAF', full_name: 'DC Abortion Fund'
    ActsAsTenant.current_tenant = tenant
    ActsAsTenant.test_tenant = tenant
  end

  def teardown_tenant
    ActsAsTenant.current_tenant = nil
    ActsAsTenant.test_tenant = nil
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
