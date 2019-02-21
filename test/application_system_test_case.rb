require 'test_helper'
require 'integration_helper'
require "capybara/rspec/matchers"

# Set systemtest behavior
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include IntegrationHelper
  include OmniauthMocker
  include Capybara::RSpecMatchers

  before { Capybara.reset_sessions! }

  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
end
