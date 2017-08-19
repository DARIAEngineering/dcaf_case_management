require 'test_helper'
require 'omniauth_helper'

Capybara.save_path = "#{ENV.fetch('CIRCLE_ARTIFACTS', Rails.root.join('tmp/capybara'))}" if ENV['CIRCLE_ARTIFACTS']

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # include IntegrationSystemTestHelpers
  include OmniauthMocker

  before { Capybara.reset_sessions! }
  OmniAuth.config.test_mode = true

  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
  puts ENV['CIRCLE_ARTIFACTS']

  def with_modified_env(options, &block)
    ClimateControl.modify(options, &block)
  end

  def log_in_as(user, line = 'DC')
    log_in user
    select_line line
  end

  def log_in(user)
    visit root_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Sign in'
  end

  def select_line(line = 'DC')
    choose line
    click_button 'Select your line for this session'
  end

  def wait_for_element(text)
    has_content? text
  end

  def wait_for_no_element(text)
    has_no_content? text
  end

  def sign_out
    click_link @user.name
    click_link 'Sign Out'
  end

  def wait_for_ajax
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until _finished_all_ajax_requests?
    end
  end

  def _finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end

  def go_to_dashboard
    click_link "DARIA - #{(ENV['FUND'] ? ENV['FUND'] : Rails.env)}"
  end

  def click_away_from_field
    find('body').click
    fill_in 'First and last name', with: nil
    wait_for_ajax
  end
end
