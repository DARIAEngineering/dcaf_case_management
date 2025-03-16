# Helpers for browser junk
module IntegrationHelper
  def t(string)
    I18n.t(string)
  end
  
  def sign_in(user)
    post user_session_path \
      'user[email]' => user.email,
      'user[password]' => user.password
  end

  def choose_line(line)
    post lines_path, params: { line_id: line.id }
  end

  def log_in_as(user, line = nil)
    log_in user
    if Line.count > 1
      select_line line || Line.first
    end
  end

  def log_in(user)
    visit root_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_on 'Sign in with password'
  end

  def select_line(line)
    wait_for_element line.name
    choose line.name
    click_on 'Get started'
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
    wait_for_element @user.name
    click_on @user.name
    wait_for_element 'Sign Out'
    click_on 'Sign Out'
    wait_for_element 'Sign in with password' # a short wait for safety
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
    click_on "DARIA - #{ActsAsTenant.current_tenant.full_name}"
  end

  def click_away_from_field
    # close the flash if it's in the way
    begin
      find('#flash button.close')&.click
    rescue Capybara::ElementNotFound
    end

    find('nav').click
    wait_for_ajax
  end

  def fill_in_field_with_autosave(locator, with:)
    fill_in locator, with: with
    sleep 0.3 # let frontend debounce do its thing
  end
end
