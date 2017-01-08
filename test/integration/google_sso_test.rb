require 'test_helper'
require 'omniauth_helper'

class GoogleSSOTest < ActionDispatch::IntegrationTest
  describe 'access top page' do
    it 'can sign in with Google Auth Account' do
      visit('/users/sign_in')
      page.has_content?('Sign in with Google')
      click_link('Sign in with Google')
    end
  end
end
