require 'test_helper'
require 'integration_helper'

# Hack from https://github.com/teamcapybara/capybara/issues/2800#issuecomment-3172247546
module Selenium
  module WebDriver
    module Error
      class UnknownError
        alias old_initialize initialize

        def initialize(msg = nil)
          if msg&.include?('Node with given id does not belong to the document')
            raise StaleElementReferenceError, msg
          end
          old_initialize(msg)
        end
      end
    end
  end
end

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
  browser = ENV['GITHUB_WORKFLOW'] ? :headless_chrome : :chrome

  # if in docker, run headless firefox
  browser = ENV['DOCKER'] ? :headless_firefox : browser

  driven_by :selenium, using: browser
end
