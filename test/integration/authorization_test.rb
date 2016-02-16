require 'test_helper'

class AuthorizationTest < ActionDispatch::IntegrationTest
  describe 'logging in successfully' do 
    it 'should root to the sign in page' do 
      get root_url
      assert_redirected_to new_user_session_url
    end

    it 'should display a success message afterwards' do 
    end
  end

  describe 'the page navbar' do 
    it 'should have a name in the top corner' do 
    end

    it 'should have a sign out link' do 
    end
  end


  describe 'logging in unsuccessfully' do
    it 'should bump you back to root' do 
    end

    it 'should not display your name' do 
    end

    it 'should display a status message' do 
    end
  end

  describe 'alter user info' do 
    it 'should let you change name and email' do 
    end

    it 'should let you change email' do 
    end 

    it 'should let you change your password' do 
    end

    it 'should veto changes without current password' do 
    end
  end

  describe 'signing out' do 
    it 'should send you back to the root directory' do 
    end

    it 'should display a sign out message' do 
    end

    it 'should prevent you from being able to get to the cases index afterwards' do 
    end
  end
end
