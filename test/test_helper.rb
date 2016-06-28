require 'simplecov'
SimpleCov.start 'rails'

require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
require 'capybara/rails'
require 'capybara/poltergeist'
Minitest::Reporters.use!
# Capybara.javascript_driver = :poltergeist

DatabaseCleaner.clean_with :truncation

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  before { DatabaseCleaner.start }
  after  { DatabaseCleaner.clean }
end

class ActionDispatch::IntegrationTest
  include Capybara::DSL

  def log_in_as(user)
    visit root_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Sign in'
  end

  def sign_out
    click_link 'Sign out'
  end
end

class ActionController::TestCase
  include Devise::TestHelpers
end
