require 'test_helper'

class PasswordResetTest < ActionDispatch::IntegrationTest
  def setup
    @user = create :user
    visit root_url 
  end

  describe 'resending password' do 
    it 'should work' do 
      assert has_link? 'Forgot password?'
      click_link 'Forgot password?'
      assert_routing '/users/password/new'
    end
  end
end
