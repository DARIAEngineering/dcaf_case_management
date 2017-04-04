require 'test_helper'
require 'omniauth_helper'

class OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
    request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:google_oauth2]
  end

  # TODO add an everything's okay alarm for google_oauth2
  it 'should be the devise controller' do
    assert :devise_controller?
  end
end
