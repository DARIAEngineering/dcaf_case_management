require 'test_helper'
require 'integration_helper'
require 'capybara/selenium/driver'

# Set systemtest behavior
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include IntegrationHelper
  include OmniauthMocker

  before do
    Capybara.reset_sessions!
    PaperTrail.enabled = true
    PaperTrail.request.enabled = true
  end

  after do
    PaperTrail.enabled = false
    PaperTrail.request.enabled = false
  end
   # Use Capybara's built-in headless Chrome driver
  if ENV['GITHUB_WORKFLOW'] || ENV['DOCKER']
    driven_by :selenium, using: :selenium_chrome_headless do |driver_options|
      browser_options = Selenium::WebDriver::Chrome::Options.new
      browser_options.add_argument('--headless=new')
      browser_options.add_argument('--disable-gpu')
      browser_options.add_argument('--disable-site-isolation-trials')
      browser_options.add_argument('--disable-background-timer-throttling')
      browser_options.add_argument('--disable-backgrounding-occluded-windows')
      browser_options.add_argument('--disable-renderer-backgrounding')

      driver_options[:options] = browser_options
    end
  else
    driven_by :selenium, using: :chrome
  end
end
