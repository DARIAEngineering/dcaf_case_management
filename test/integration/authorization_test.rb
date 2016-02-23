require 'test_helper'

class AuthorizationTest < ActionDispatch::IntegrationTest
  def setup
    @user = create :user
    log_in_as @user
  end

  describe 'logging in successfully' do
    it 'should display a success message after successful login' do
      assert_text 'Signed in successfully.'
    end
  end

  describe 'the page navbar' do
    it 'should have a name in the top corner' do
      assert has_link? @user.name, href: edit_user_registration_path
    end

    it 'should have a sign out link' do
      assert has_link? 'Sign out', href: destroy_user_session_path
    end
  end

  describe 'logging in unsuccessfully' do
    it 'should bump you back to root' do
      sign_out
      @user.password = 'not_valid'
      log_in_as @user
      assert_equal current_path, new_user_session_path
      assert_text 'Invalid email or password.'
      assert_no_text @user.name
    end
  end

  describe 'alter user info' do
    it 'should let you change name and email' do
      visit edit_user_registration_path
      fill_in 'Name', with: 'Thorny'
      fill_in 'Current password', with: @user.password
      click_button 'Update info'
      assert has_link? 'Thorny', href: edit_user_registration_path
    end

    it 'should let you change email' do
      visit edit_user_registration_path
      fill_in 'Email', with: 'different@email.com'
      fill_in 'Current password', with: @user.password
      click_button 'Update info'
      visit edit_user_registration_path
      assert_text 'different@email.com'
    end

    it 'should let you change your password' do
      visit edit_user_registration_path
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
      visit edit_user_registration_path
      fill_in 'Name', with: 'Bad Name'
      click_button 'Update info'
      assert_text "Current password can't be blank"
      fill_in 'Current password', with: 'not_a_real_password'
      click_button 'Update info'
      assert_text 'Current password is invalid'
      assert_no_text 'Bad Name'
    end
  end

  describe 'signing out' do
    it 'should send you back to the sign in path' do
      sign_out
      assert_equal current_path, new_user_session_path
      assert_text 'You need to sign in or sign up before continuing.'
    end

    it 'should prevent you from being able to get to data afterwards' do
      sign_out
      visit pregnancies_path
      assert_equal current_path, new_user_session_path
      assert_text 'You need to sign in or sign up before continuing.'
    end
  end
end
