require 'test_helper'

# Test oauth sign in behavior
class GoogleSSOTest < ActionDispatch::IntegrationTest
  describe 'access top page' do
    before do
      create :line
      mock_omniauth
    end

    it 'can sign in with Google Auth Account' do
      @user = create :user, email: 'test@gmail.com'
      visit root_path
      wait_for_element 'Sign in with Google'
      click_button 'Sign in with Google'
      wait_for_no_element 'Sign in with Google'

      assert has_content? @user.name
    end

    it 'will reject sign ins if email is not associated with a user' do
      visit root_path
      assert has_content? 'Forgot your password?'
      click_button 'Sign in with Google'

      assert has_content? 'Forgot your password?'
    end
    it 'sign in page is accessible' do
      visit root_path
      wait_for_element 'Sign in with Google'
      assert_accessible(page)
  end
end
