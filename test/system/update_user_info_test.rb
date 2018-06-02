require 'application_system_test_case'

class UpdateUserInfoTest < ApplicationSystemTestCase
  before do
    @user = create :user
    log_in_as @user
    visit edit_user_registration_path
  end

  describe 'alter user info' do
    it 'should let you change name' do
      fill_in 'First and last name', with: 'Thorny'
      fill_in 'Current password', with: @user.password
      click_button 'Update info'
      assert has_text? 'Thorny'
    end

    it 'should not let you change email' do
      assert has_text? 'Email'
      refute has_field? 'Email'
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
