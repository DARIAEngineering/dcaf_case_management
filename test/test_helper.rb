require 'simplecov'
SimpleCov.start 'rails'

require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
require 'minitest/autorun'
require 'capybara/rails'
require 'capybara/poltergeist'
require 'capybara-screenshot/minitest'
require 'omniauth_helper'
require 'rack/test'
Minitest::Reporters.use!

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false)
end

DatabaseCleaner.clean_with :truncation

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  before { DatabaseCleaner.start }
  after  { DatabaseCleaner.clean }

  def create_insurance_config
    create :config, config_key: 'insurance',
                    config_value: { options: ['DC Medicaid', 'Other state Medicaid'] }
  end

  def create_external_pledge_source_config
    create :config, config_key: 'external_pledge_source',
                    config_value: { options: ['Baltimore Abortion Fund', 'Tiller Fund (NNAF)', 'NYAAF (New York)'] }
  end

  def create_language_config
    create :config, config_key: 'language',
                    config_value: { options: ['Spanish', 'French', 'Korean'] }
  end
end
  
# Save screenshots if integration tests fail
Capybara.save_path = "#{ENV.fetch('CIRCLE_ARTIFACTS', Rails.root.join('tmp/capybara'))}" if ENV['CIRCLE_ARTIFACTS']

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Capybara::Screenshot::MiniTestPlugin
  include OmniauthMocker
  OmniAuth.config.test_mode = true

  before { Capybara.reset_sessions! }

  # for controllers
  def sign_in(user)
    post user_session_path \
      "user[email]" => user.email,
      "user[password]" => user.password
  end

  def choose_line(line)
    post lines_path, params: { line: line.to_s }
  end

  # for proper integration tests
  def log_in_as(user, line = 'DC')
    log_in user
    select_line line
  end

  def log_in(user)
    visit root_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Sign in with password'
  end

  def select_line(line = 'DC')
    choose line
    click_button 'Select your line for this session'
  end

  def wait_for_element(text)
    has_content? text
  end

  def wait_for_no_element(text)
    has_no_content? text
  end

  def sign_out
    click_link "#{@user.name}"
    click_link 'Sign Out'
  end

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until _finished_all_ajax_requests?
    end
  end

  def _finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end

  def go_to_dashboard
    click_link "DARIA - #{(ENV['FUND'] ? ENV['FUND'] : Rails.env)}"
  end

  def click_away_from_field
    find('body').click
    fill_in 'First and last name', with: nil
    wait_for_ajax
  end
end

class ActionController::TestCase
  # include Devise::TestHelpers
  include Devise::Test::ControllerHelpers
end
