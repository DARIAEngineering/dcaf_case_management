require 'test_helper'
require 'integration_helper'

# Set systemtest behavior
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include IntegrationHelper
  include OmniauthMocker

  before { Capybara.reset_sessions! }

  # if in CI, run system tests headlessly.
  browser = ENV['GITHUB_WORKFLOW'] ? :headless_chrome : :chrome
  driven_by :selenium, using: browser
end
