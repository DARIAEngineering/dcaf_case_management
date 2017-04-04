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
end

# Save screenshots if integration tests fail
Capybara.save_path = "#{ENV.fetch('CIRCLE_ARTIFACTS', Rails.root.join('tmp/capybara'))}" if ENV['CIRCLE_ARTIFACTS']

class ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Capybara::Screenshot::MiniTestPlugin
  include OmniauthMocker
  OmniAuth.config.test_mode = true

  before { Capybara.reset_sessions! }

  def log_in_controller(user)
    post user_session_path \
      "user[email]" => user.email,
      "user[password]" => user.password
  end

  def log_in_as(user, line = 'DC')
    log_in user
    select_line line
  end

  def log_in(user)
    visit root_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Sign in'
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
    click_link 'Sign out'
  end

  def wait_for_ajax
    counter = 0
    while page.execute_script('return $.active').to_i > 0
      counter += 1
      sleep(0.1)
      raise 'Ajax request took longer than 5 seconds, failing' if counter >= 50
    end
  end
end

class ActionController::TestCase
  # include Devise::TestHelpers
  include Devise::Test::ControllerHelpers
end
