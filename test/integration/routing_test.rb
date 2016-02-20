require 'test_helper'

class RoutingTest < ActionDispatch::IntegrationTest
  def setup
    visit root_url 
  end

  it 'should root to the sign in page' do 
    assert_equal current_path, new_user_session_path
    assert_text 'You need to sign in or sign up before continuing'
    assert has_field? 'Email'
    assert has_field? 'Password'
    assert has_button? 'Sign in'
  end
end
