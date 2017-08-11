require "capybara/poltergeist"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Rack::Test
  # driven_by :rack_test

  # capybara-webkit
  # Capybara::Webkit.configure do |config|
  #   config.raise_javascript_errors = false
  # end
  # driven_by :webkit

  # Poltergeist
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, js_errors: false)
  end
  driven_by :poltergeist
end