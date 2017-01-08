require 'test_helper'
require 'omniauth_helper'

class GoogleSSOTest < ActionDispatch::IntegrationTest
  describe 'access top page' do
    before do
      mock_omniauth
      create :user, email: 'test@gmail.com'
    end

    it 'can sign in with Google Auth Account' do
      visit('/users/sign_in')
      page.has_content?('Sign in with Google')
      click_link('Sign in with Google')

      assert has_content? 'Sign out'
    end
  end
end
