require 'test_helper'
require 'omniauth_helper'

class OmniauthCallbacksControllerTest < ActionController::TestCase
  before do 
    request.env["devise.mapping"] = Devise.mappings[:user] 
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2] 
  end

  describe 'access top page' do
    it 'can sign in with Google Auth Account' do
      visit('/users/sign_in')
      page.has_content?('Sign in with Google')
      click_link('Sign in with Google')
    end
  end

  it 'should be the devise controller' do
    assert :devise_controller?
  end
end
