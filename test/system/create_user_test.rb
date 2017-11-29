require 'application_system_test_case'

# Behavior and permissioning around creating new users
class CreateUserTest < ApplicationSystemTestCase
  describe 'nonadmin user' do
    before { visit root_path }

    it 'should not let you create a user' do
      assert has_no_link? 'Sign up'
    end
  end

  describe 'admin user' do
    before do
      @user = create :user, role: :admin
      log_in_as @user
      visit new_user_path
    end

    it 'should be able to create user' do
      assert has_field? 'Email'
      fill_in 'Email', with: 'test@example.com'
      fill_in 'Name', with: 'Test User'
      click_button 'Add'
      assert has_content? 'Active', count: 2
    end

    it 'should validate form correctly' do
      click_button 'Add'
      assert_text "can't be blank"

      fill_in 'Email', with: 'test@test'
      click_button 'Add'
      assert_text 'is invalid'
    end
  end

  describe 'non admin user' do
    before do
      @user = create :user, role: :cm
      log_in_as @user
    end

    it 'should not show add user button' do
      assert_no_text 'Create User'
    end

    it 'should redirect to root path if navigate to form' do
      assert_not @user.admin?
      visit new_user_path
      assert_equal current_path, root_path
    end
  end

  describe 'data volunteer user' do
    before do
      @user = create :user, role: :data_volunteer
      log_in_as @user
    end

    it 'should not show add user button' do
      assert_no_text 'Create User'
    end

    it 'should redirect to root path if navigate to form' do
      assert_not @user.admin?
      visit new_user_path
      assert_equal current_path, root_path
    end
  end

  describe 'not logged in' do
    it 'should show nothing if not logged in' do
      visit new_user_path
      assert_equal current_path, new_user_session_path
    end
  end
end
