require 'test_helper'
require 'omniauth_helper'

class OmniauthCallbacksControllerTest < ActionController::TestCase
  describe 'access top page' do
    it 'can sign in with Google Auth Account' do
      visit root_path
      page.should have_content("Sign in with Google")
      click_link "Sign in with Google"
    end
  end

  it 'should be the devise controller' do
    assert :devise_controller?
  end
end
