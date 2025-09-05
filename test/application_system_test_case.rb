require 'test_helper'
require 'integration_helper'
require 'capybara/rails'
require 'capybara/selenium/driver'

# Set systemtest behavior
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include IntegrationHelper
  include OmniauthMocker

  # Configure webdrivers to use the latest compatible version
  #Webdrivers::Chromedriver.update

  # Explicitly register a selenium chrome headless driver
  Capybara.register_driver :headless_chrome do |app|
    chrome_options = Selenium::WebDriver::Chrome::Options.new(
      args: [
        '--headless=new',
        '--disable-gpu',
        '--no-sandbox',
        '--disable-dev-shm-usage',
        '--disable-site-isolation-trials',
        '--disable-background-timer-throttling',
        '--disable-backgrounding-occluded-windows',
        '--disable-renderer-backgrounding'
      ]
    )

    Capybara::Selenium::Driver.new(
      app,
      browser: :chrome,
      options: chrome_options
    )
  end

  # Conditionally select driver based on environment
  if ENV['GITHUB_WORKFLOW'] || ENV['DOCKER']
    driven_by :selenium, using: :headless_chrome
  else
    driven_by :selenium, using: :chrome
  end

  before do
    Capybara.reset_sessions!
    PaperTrail.enabled = true
    PaperTrail.request.enabled = true
  end

  after do
    PaperTrail.enabled = false
    PaperTrail.request.enabled = false
  end
end
