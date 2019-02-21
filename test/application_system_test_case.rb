require 'test_helper'
require 'integration_helper'

# Set systemtest behavior
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include IntegrationHelper
  include OmniauthMocker

  before { Capybara.reset_sessions! }

  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
end
