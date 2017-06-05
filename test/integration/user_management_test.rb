require 'test_helper'

class UserManagementTest < ActionDispatch::IntegrationTest

  before do
    Capybara.current_driver = :poltergeist
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
      log_in @user
    end

    it 'should not be able to access Admin links' do
      assert has_no_link? 'Admin'
    end

    it 'should redirect to main dashboard' do
      visit users_path
      assert_text 'Build your call list'
    end
  end

  describe 'data volunteer' do
    before do
      log_in @data_volunteer
    end

    it 'should not be able to access user management' do
      click_link 'Admin'
      assert_no_text 'User Management'
    end

  end

  describe 'admin user' do
    before do
      log_in @admin
    end

    it 'should be able to access user management' do
      click_link 'Admin'
      assert_text 'User Management'
      click_link 'User Management'
      wait_for_element 'User Account Management'
      click_link 'Add New User'
    end
  end

  describe 'user management' do
    before do
      log_in @admin
      click_link 'Admin'
      assert_text 'User Management'
      click_link 'User Management'
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

  describe 'edit a user' do
    before do
      log_in @admin
      click_link 'Admin'
      assert_text 'User Management'
      click_link 'User Management'
      wait_for_element 'User Account Management'
      click_link 'john'
      wait_for_element 'User details'
    end

    # TODO lock test
    # it 'allows user locking' do
    #   assert_text 'Status: Active'
    #   click_link 'Lock Account'
    #   wait_for_element 'Unlock Account'
    #   assert_text 'Status: Locked'
    # end

    it 'allows name editing' do
      fill_in 'Name', with: 'johan'
      click_button 'Save'
      wait_for_element 'Successfully updated user details'
      assert_text 'johan'
    end

    it 'allows email editing' do
      fill_in 'Email', with: 'johan@gmail.com'
      click_button 'Save'
      wait_for_element 'Successfully updated user details'
      # assert_text 'johan@gmail.com'
    end

    # TODO figure out a way to show error
    it 'disallows role editing' do
      select 'Admin', from: "user_role"
      click_button 'Save'
      wait_for_element 'Successfully updated user details'
      assert_equal 'Case manager', find_field('user_role').find('option[selected]').text
    end
  end


end
