require 'test_helper'

class CreateUserTest < ActionDispatch::IntegrationTest
  before do
    Capybara.current_driver = :poltergeist
  end

  after do
    Capybara.use_default_driver
  end

  describe 'admin user' do
    before do
      @user = create :user, role: :admin
      log_in_as @user
    end

    it 'should be able to create user' do
      assert_difference('User.count', 1) do
        assert_text 'Create User'
        click_link 'Create User'

        assert has_field? 'Email'
        fill_in 'Email', with: 'test@test.com'

        assert has_field? 'Name'
        fill_in 'Name', with: 'Test User'

        assert has_field? 'Password'
        fill_in 'Password', with: 'FCZCidQP4C8GTz'

        assert has_field? 'Password confirmation'
        fill_in 'Password confirmation', with: 'FCZCidQP4C8GTz'

        click_button 'Add'
      end

      user = User.find_by(email: 'test@test.com')
      assert_not_nil user
      assert_equal user.name, 'Test User'
    end

    it 'should validate form correctly' do
      visit new_user_path
      click_button 'Add'

      assert_text "Email can't be blank"
      assert_text "Name can't be blank"
      assert_text "Password can't be blank"

      fill_in 'Email', with: 'test@test'
      fill_in 'Password', with: 'asdfasdf'
      click_button 'Add'

      assert_text 'Email is invalid'
      assert_text 'must include at least one lowercase letter, one uppercase '\
                  'letter, and one digit.'
      assert_text "Password confirmation doesn't match Password"
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

    it 'should raise if navigate to form' do
      assert_not @user.admin?
      visit new_user_path
      assert_equal 'Permission Denied', page.text
    end
  end

  describe 'not logged in' do
    it 'should show nothing if not logged in' do
      visit new_user_path
      assert_equal current_path, new_user_session_path
    end
  end
end
