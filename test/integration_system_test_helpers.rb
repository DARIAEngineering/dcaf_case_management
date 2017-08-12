module IntegrationSystemTestHelpers
  include Capybara::DSL
  include Capybara::Screenshot::MiniTestPlugin

  # for controllers
  def sign_in(user)
    post user_session_path \
      "user[email]" => user.email,
      "user[password]" => user.password
  end

  def choose_line(line)
    post lines_path, params: { line: line.to_s }
  end

  # for proper integration tests
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
    click_link "#{@user.name}"
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
end
