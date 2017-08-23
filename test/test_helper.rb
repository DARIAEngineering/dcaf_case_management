require 'simplecov'
SimpleCov.start 'rails'

require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
# require 'minitest/reporters'
require 'minitest/autorun'
# require 'omniauth_helper'
# require 'rack/test'
# require 'capybara/poltergeist'
# Minitest::Reporters.use! Minitest::Reporters::ProgressReporter.new

DatabaseCleaner.clean_with :truncation

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  before { DatabaseCleaner.start }
  after  { DatabaseCleaner.clean }
end

# Save screenshots if integration tests fail - I don't THINK we need this anymore

class ActionDispatch::IntegrationTest
  # de facto controller tests

  def sign_in(user)
    post user_session_path \
      'user[email]' => user.email,
      'user[password]' => user.password
  end

  def choose_line(line)
    post lines_path, params: { line: line.to_s }
  end
end
