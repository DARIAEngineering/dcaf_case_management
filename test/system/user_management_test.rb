require 'application_system_test_case'

# Confirm user management functionality
class UserManagementTest < ApplicationSystemTestCase
  before do
    @user = create :user,
                   name: 'john',
                   email: 'user@dcaf.com',
                   role: :cm

    @admin = create :user,
                    name: 'admin',
                    email: 'admin@dcaf.com',
                    role: :admin

    @data_volunteer = create :user,
                             name: 'volunteer',
                             email: 'data@gmail.com',
                             role: :data_volunteer
  end

  describe 'case manager' do
    before do
      log_in_as @user
    end

    it 'should redirect to main dashboard' do
      visit users_path
      assert_text 'Build your call list'
      assert_no_text 'User Account Management'
    end
  end

  describe 'data volunteer' do
    before do
      log_in @data_volunteer
    end

    it 'should not be able to access user management' do
      click_on 'Admin'
      assert_no_text 'User Account Management'
    end
  end

  describe 'admin user' do
    before do
      log_in @admin
    end

    it 'should be able to access user management' do
      click_on 'Admin'
      assert has_content? 'User Management'
      assert_text 'User Management'
      click_on 'User Management'
      wait_for_element 'User Account Management'
      assert has_content? 'User Account Management'
      click_on 'Add New User'
    end
  end

  describe 'user management' do
    before do
      log_in @admin
      click_on 'Admin'
      assert_text 'User Management'
      click_on 'User Management'
      wait_for_element 'User Account Management'
    end

    it 'should display all users' do
      page.has_css?("#user-list tbody tr", :count => 3)
    end

    it 'should search names' do
      fill_in 'search_field', with: 'john'
      find('#search_button').click
      wait_for_ajax
      page.has_css?("#user-list tbody tr", :count => 1)
    end

    it 'should search emails' do
      fill_in 'search_field', with: 'user@dcaf.com'
      find('#search_button').click
      wait_for_ajax
      page.has_css?("#user-list tbody tr", :count => 1)
    end

    it 'should return empty' do
      fill_in 'search_field', with: 'nonexistant'
      find('#search_button').click
      wait_for_ajax
      page.has_css?("#user-list tbody tr", :count => 0)
    end

    it 'should return full list after inputting blank search field' do
      fill_in 'search_field', with: 'user@dcaf.com'
      find('#search_button').click
      wait_for_ajax
      page.has_css?("#user-list tbody tr", :count => 1)
      fill_in 'search_field', with: ''
      find('#search_button').click
      wait_for_ajax
      page.has_css?("#user-list tbody tr", :count => 3)
    end
  end

  describe 'editing a user' do
    before do
      log_in_as @admin
      click_on 'Admin'
      assert_text 'User Management'
      click_on 'User Management'
      wait_for_element 'User Account Management'
      click_on @user.name
      wait_for_element 'User details'
    end

    it 'allows user locking' do
      click_on 'Lock account'
      wait_for_element 'Unlock account'
      within :css, "#user-#{@user.id}" do
        assert_text 'Locked by admin'
      end
    end

    it 'allows name editing' do
      fill_in 'Name', with: 'johan'
      click_on 'Save'
      wait_for_element 'Successfully updated user details'
      assert_text 'johan'
    end

    it 'allows email editing' do
      fill_in 'Email', with: 'johan@gmail.com'
      click_on 'Save'
      wait_for_element 'Successfully updated user details'
      click_on @user.name
      assert has_field? 'Email', with: 'johan@gmail.com'
    end
  end
end
