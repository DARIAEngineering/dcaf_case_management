require 'application_system_test_case'

class PasswordResetTest < ApplicationSystemTestCase
  before do
    @user = create :user
  end

  describe 'password reset page accessibility' do
    before do
      visit root_path
    end

    # problematic test -- Circular dependency detected while autoloading
    # constant Devise::PasswordsController.
    it 'should have a link to the password reset page' do
      assert has_link? 'Forgot your password?'
      click_link 'Forgot your password?'
      wait_for_element 'Password Reset'

      assert_routing new_user_password_path, controller: 'devise/passwords',
                                             action: 'new'
      assert_text 'Password Reset'
    end
  end

  describe 'password reset page function' do
    before do
      visit new_user_password_path
    end

    it 'should respond if email does not exist' do
      fill_in 'Email', with: 'not_a_real_email@gmail.com'
      click_button 'Send me password reset instructions'
      assert_text 'If your email address exists in our database, you will ' \
                  'receive a password recovery link at your email address ' \
                  'in a few minutes'
      assert_routing new_user_password_path, controller: 'devise/passwords',
                                             action: 'new'
    end

    it 'should send a password reset if email does exist' do
      fill_in 'Email', with: @user.email
      click_button 'Send me password reset instructions'
      assert_text 'If your email address exists in our database, you will ' \
                  'receive a password recovery link at your email address ' \
                  'in a few minutes'
      assert_routing new_user_password_path, controller: 'devise/passwords',
                                             action: 'new'
    end
  end
end