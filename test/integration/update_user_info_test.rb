require 'test_helper'

class UpdateUserInfoTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    log_in_as @user
    visit edit_user_registration_path
  end

  describe 'alter user info' do
    it 'should let you change name and email' do
      fill_in 'Name', with: 'Thorny'
      fill_in 'Current password', with: @user.password
      click_button 'Update info'
      assert has_link? 'Thorny', href: edit_user_registration_path
    end

    it 'should let you change email' do
      fill_in 'Email', with: 'different@email.com'
      fill_in 'Current password', with: @user.password
      click_button 'Update info'
      visit edit_user_registration_path
      assert_text 'different@email.com'
    end

    it 'should let you change your password' do
      fill_in 'Password', with: 'another_password'
      fill_in 'Password confirmation', with: 'another_password'
      fill_in 'Current password', with: @user.password
      click_button 'Update info'
      sign_out
      @user.password = 'another_password'
      log_in_as @user
      assert_text 'Signed in successfully.'
    end

    it 'should veto changes without current password' do
      fill_in 'Name', with: 'Bad Name'
      click_button 'Update info'
      assert_text "Current password can't be blank"
      fill_in 'Current password', with: 'not_a_real_password'
      click_button 'Update info'
      assert_text 'Current password is invalid'
      assert_no_text 'Bad Name'
    end
  end
end
