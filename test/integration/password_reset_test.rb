require 'test_helper'

class PasswordResetTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
  end

  describe 'password reset page accessibility' do
    before do
      visit root_path
    end

    # problematic test -- Circular dependency detected while autoloading constant Devise::PasswordsController l16
    it 'should have a link to the password reset page' do
      assert has_link? 'Forgot your password?'
      click_link 'Forgot your password?'
      assert_routing new_user_password_path, controller: 'devise/passwords',
                                             action: 'new'
      assert_text 'Password Reset'
    end
  end

  describe 'password reset page function' do
    before do
      visit new_user_password_path
    end

    after do
      Devise.mailer.deliveries.clear
    end

    it 'should error if email does not exist' do
      assert_no_difference 'Devise.mailer.deliveries.count' do
        fill_in 'Email', with: 'not_a_real_email@gmail.com'
        click_button 'Send me password reset instructions'
      end
      assert_text 'If your email address exists in our database, you will ' \
                  'receive a password recovery link at your email address ' \
                  'in a few minutes'
      assert_routing new_user_password_path, controller: 'devise/passwords',
                                             action: 'new'
    end

    it 'should send a password reset if email does exist' do
      assert_difference 'Devise.mailer.deliveries.count', 1 do
        fill_in 'Email', with: @user.email
        click_button 'Send me password reset instructions'
      end
      assert_text 'If your email address exists in our database, you will ' \
                  'receive a password recovery link at your email address ' \
                  'in a few minutes'
      assert_routing new_user_password_path, controller: 'devise/passwords',
                                             action: 'new'
      assert_match /reset_password_token/, Devise.mailer.deliveries.last.to_s
    end
  end
end
