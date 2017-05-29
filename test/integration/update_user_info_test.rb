require 'test_helper'

class UpdateUserInfoTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
    @user = create :user
    log_in_as @user
    visit edit_user_registration_path
  end

  describe 'alter user info' do
    it 'should let you change name and email' do
      fill_in 'First and last name', with: 'Thorny'
      fill_in 'Current password', with: @user.password
      click_button 'Update info'
      assert has_text? 'Thorny'
    end

    it 'should let you change email' do
      fill_in 'Email', with: 'different@email.com'
      fill_in 'Current password', with: @user.password
      click_button 'Update info'
      visit edit_user_registration_path
      assert_text 'different@email.com'
    end

    describe 'changing your password' do
      before do
        fill_in 'Password', with: 'Different_P4ss'
        fill_in 'Password confirmation', with: 'Different_P4ss'
        fill_in 'Current password', with: @user.password
        click_button 'Update info'
        sign_out
      end

      after { Devise.mailer.deliveries.clear }

      it 'should let you change your password' do
        @user.password = 'Different_P4ss'
        log_in_as @user
        refute has_text? 'Signed in successfully.'
      end

      it 'should send an email notifying' do
        email_content = ActionMailer::Base.deliveries.last.to_s
        assert_match /Your DARIA password has changed/, email_content
        assert_match @user.email, email_content
      end
    end

    it 'should veto changes without current password' do
      fill_in 'First and last name', with: 'Bad Name'
      click_button 'Update info'
      assert_text "Current password can't be blank"
      fill_in 'Current password', with: 'not_a_real_pAssw0rd'
      click_button 'Update info'
      assert_text 'Current password is invalid'
      assert_no_text 'Bad Name'
    end
  end
end
