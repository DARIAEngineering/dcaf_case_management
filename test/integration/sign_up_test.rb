require 'test_helper'

class SignUpTest < ActionDispatch::IntegrationTest
  before do
    visit root_path
    # click_link 'Sign up'
  end

  describe 'should not let you create a user' do
    it 'should not offer a sign up link' do
      assert has_no_link? 'Sign up'
    end
  end

  # describe 'creating a new user' do
  #   before do
  #     fill_in 'Email', with: Faker::Internet.email
  #     fill_in 'Name', with: 'A Real Person'
  #     fill_in 'Password', with: 'password', match: :prefer_exact
  #     fill_in 'Password confirmation', with: 'password', match: :prefer_exact
  #   end

  #   it 'should create a user' do
  #     assert_difference 'User.count', 1 do
  #       click_button 'Sign up'
  #     end
  #   end

  #   it 'should save that user name' do
  #     click_button 'Sign up'
  #     assert has_link? 'A Real Person'
  #   end
  # end

  # describe 'failure conditions' do
  #   before do
  #     @user = create :user
  #   end

  #   it 'should not let you create a user twice' do
  #     assert_no_difference 'User.count' do
  #       fill_in 'Email', with: @user.email
  #       fill_in 'Name', with: 'A Real Person'
  #       fill_in 'Password', with: 'password', match: :prefer_exact
  #       fill_in 'Password confirmation', with: 'password', match: :prefer_exact
  #       click_button 'Sign up'
  #       assert_text 'Email is already taken'
  #     end
  #   end
  # end
end
