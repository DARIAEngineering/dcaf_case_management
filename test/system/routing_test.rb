require 'application_system_test_case'

class RoutingTest < ApplicationSystemTestCase
  before do
    visit root_path
  end

  it 'should have a root with a login form' do
    assert_equal current_path, new_user_session_path
    refute has_text? 'You need to sign in or sign up before continuing'
    assert has_field? 'Email'
    assert has_field? 'Password'
    assert has_button? 'Sign in'
  end

  it 'should not display navigation partial on sign in' do
    refute has_text? 'DARIA - ' + Rails.env
    visit root_path
    @user = create :user
    log_in_as @user
    visit authenticated_root_path
    assert has_text? 'DARIA - ' + Rails.env
  end
end
