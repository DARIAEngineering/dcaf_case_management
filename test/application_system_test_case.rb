require 'test_helper'
require 'integration_helper'
require 'capybara/selenium/driver'

# Set systemtest behavior
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include IntegrationHelper
  include OmniauthMocker

  # Use Capybara's built-in headless Chrome driver
  if ENV['GITHUB_WORKFLOW'] || ENV['DOCKER']
    driven_by :selenium, using: :selenium_chrome_headless do |driver|
      driver.add_argument('--headless=new')
      driver.add_argument('--disable-gpu')
      driver.add_argument('--disable-site-isolation-trials')
      driver.add_argument('--disable-background-timer-throttling')
      driver.add_argument('--disable-backgrounding-occluded-windows')
      driver.add_argument('--disable-renderer-backgrounding')
    end
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
