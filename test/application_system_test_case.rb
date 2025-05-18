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

  # if in CI, run system tests headlessly.
  browser = :chrome

  # if in docker, run headless firefox
  browser = ENV['DOCKER'] ? :headless_firefox : browser

  driven_by :selenium, using: browser
end
