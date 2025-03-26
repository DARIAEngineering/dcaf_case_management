require 'test_helper'
require 'integration_helper'

Capybara.register_driver :local_selenium_chrome_headless do |app|
  version = Capybara::Selenium::Driver.load_selenium
  options_key = Capybara::Selenium::Driver::CAPS_VERSION.satisfied_by?(version) ? :capabilities : :options
  browser_options = Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    # These are defaults from capybara
    # https://github.com/teamcapybara/capybara/blob/0480f90168a40780d1398c75031a255c1819dce8/lib/capybara/registrations/drivers.rb#L31-L39

    opts.add_argument('--headless=new')
    opts.add_argument('--disable-gpu') if Gem.win_platform?
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    opts.add_argument('--disable-site-isolation-trials')

    # These are ones we are adding to try to workaround chrome race condition
    # weirdness.
    # https://github.com/teamcapybara/capybara/issues/2800#issuecomment-2750363862
    # Disable timers being throttled in background pages/tabs
    opts.add_argument '--disable-background-timer-throttling'

    # Normally, Chrome will treat a 'foreground' tab instead as backgrounded if the surrounding window is occluded (aka
    # visually covered) by another window. This flag disables that.
    opts.add_argument '--disable-backgrounding-occluded-windows'

    # This disables non-foreground tabs from getting a lower process priority.
    opts.add_argument '--disable-renderer-backgrounding'
  end

  Capybara::Selenium::Driver.new(app, **{ :browser => :chrome, options_key => browser_options })
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
  browser = ENV['GITHUB_WORKFLOW'] ? :local_selenium_chrome_headless : :chrome

  # if in docker, run headless firefox
  browser = ENV['DOCKER'] ? :local_selenium_chrome_headless : browser

  driven_by :selenium, using: browser
end
