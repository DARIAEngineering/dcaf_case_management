require 'application_system_test_case'

class PasswordResetTest < ApplicationSystemTestCase
  before do
    @user = create :user
  end

  describe 'password reset page accessibility' do
    before do
      visit root_path
    end

    it 'should have a link to the password reset page' do
      assert has_link? 'Forgot your password?'
      click_link 'Forgot your password?'
      wait_for_element 'Password Reset'

      assert_text 'Password Reset'
      assert current_path == new_user_password_path
    end
  end

  describe 'password reset page function' do
    before do
      visit new_user_password_path
    end

    it 'should respond if email does not exist' do
      fill_in 'Email', with: 'not_a_real_email@example.com'
      click_button 'Send me password reset instructions'

      assert_text 'If your email address exists in our database, you will ' \
                  'receive a password recovery link at your email address ' \
                  'in a few minutes'
      assert current_path == new_user_session_path
    end

    it 'should send a password reset if email does exist' do
      fill_in 'Email', with: @user.email
      click_button 'Send me password reset instructions'

      assert_text 'If your email address exists in our database, you will ' \
                  'receive a password recovery link at your email address ' \
                  'in a few minutes'
      assert current_path == new_user_session_path
    end
  end
end
