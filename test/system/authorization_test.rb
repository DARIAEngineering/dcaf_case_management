require 'application_system_test_case'

class AuthorizationTest < ApplicationSystemTestCase
  before do
    @user = create :user
    log_in_as @user
  end

  describe 'logging in successfully' do
    it 'should display a success message after successful login' do
      refute has_text? 'Signed in successfully.'
    end
  end

  describe 'the page navbar' do
    it 'should display the username in the top corner' do
      assert has_text? @user.name
    end

    it 'should have a sign out link' do
      click_link "#{@user.name}"
      assert has_link? 'Sign Out', href: destroy_user_session_path
    end
  end

  describe 'logging in unsuccessfully' do
    it 'should bump you back to root' do
      sign_out
      @user.password = 'not_valid'
      log_in @user
      assert_equal current_path, new_user_session_path
      assert_text 'Invalid Email or password.'
      assert_no_text @user.name
    end
  end

  describe 'signing out' do
    it 'should send you back to the sign in path' do
      sign_out
      assert_equal current_path, new_user_session_path
      refute has_text? 'You need to sign in or sign up before continuing.'
    end

    it 'should prevent you from being able to get to data afterwards' do
      sign_out
      visit dashboard_path
      assert_equal current_path, new_user_session_path
      refute has_text? 'You need to sign in or sign up before continuing.'
    end
  end
end
