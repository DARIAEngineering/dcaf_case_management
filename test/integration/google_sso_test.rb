require 'test_helper'

class GoogleSSOTest < ActionDispatch::IntegrationTest
  describe 'access top page' do
    before do
      mock_omniauth
    end

    it 'can sign in with Google Auth Account' do
      @user = create :user, email: 'test@gmail.com'
      visit root_path
      wait_for_element 'Sign in with Google'
      click_button 'Sign in with Google'

      assert has_content? @user.name
    end

    it 'will reject sign ins if email is not associated with a user' do
      visit root_path
      assert has_content? 'Forgot your password?'
      click_button 'Sign in with Google'

      assert has_content? 'Forgot your password?'
    end
  end
end
