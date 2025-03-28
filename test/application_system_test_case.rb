require 'test_helper'
require 'integration_helper'

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
    driven_by :selenium, using: :selenium_chrome_headless do |options|
      options.add_argument('--disable-site-isolation-trials')
      options.add_argument('--disable-background-timer-throttling')
      options.add_argument('--disable-backgrounding-occluded-windows')
      options.add_argument('--disable-renderer-backgrounding')
    end
  else
    driven_by :selenium, using: :chrome
  end
end
