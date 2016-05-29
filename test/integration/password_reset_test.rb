require 'test_helper'

class PasswordResetTest < ActionDispatch::IntegrationTest
  def setup
    @user = create :user
  end

  describe 'password reset page accessibility' do
    before do
      visit root_url
    end

    it 'should have a link to the password reset page' do
      assert has_link? 'Forgot your password?'
      click_link 'Forgot your password?'
      assert_routing new_user_password_path, controller: 'devise/passwords', action: 'new'
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

    it 'should errror if email does not exist' do
      fill_in 'Email', with: 'not_a_real_email@gmail.com'
      click_button 'Send me password reset instructions'
      assert_text 'Email not found'
      assert_routing new_user_password_path, controller: 'devise/passwords', action: 'new'
      assert_equal Devise.mailer.deliveries.count, 0
    end

    it 'should send a password reset if email does exist' do
      fill_in 'Email', with: @user.email
      click_button 'Send me password reset instructions'
      assert_text 'You will receive an email with instructions on how to reset your password in a few minutes.'
      assert_routing new_user_session_path, controller: 'devise/sessions', action: 'new'

      # confirm email got sent
      assert_equal Devise.mailer.deliveries.count, 1
      assert_match /reset_password_token/, Devise.mailer.deliveries.first.to_s
    end
  end
end
