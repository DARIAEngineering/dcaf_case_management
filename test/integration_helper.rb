# Helpers for browser junk
module IntegrationHelper
  def log_in_as(user, line = 'DC')
    log_in user
    select_line line
  end

  def log_in(user)
    visit root_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Sign in with password'
  end

  def select_line(line = 'DC')
    choose line
    click_button 'Start'
  end

  def wait_for_element(text)
    has_content? text
  end

  def wait_for_no_element(text)
    has_no_content? text
  end

  def wait_for_css(selector)
    has_css? selector
  end

  def wait_for_no_css(selector)
    has_no_css? selector
  end

  def sign_out
    click_link @user.name
    click_link 'Sign Out'
  end

  def log_out
    sign_out
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
    wait_for_ajax
  end
end
