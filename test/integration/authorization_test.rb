require 'test_helper'

class AuthorizationTest < ActionDispatch::IntegrationTest
  describe 'logging in successfully' do 
    it 'should root to the sign in page' do 
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
    # visit '/'
    # create garbage user
    # log in 
  end

  describe 'alter user info' do 
    before do 
      # visit thing
      # sign in 
    end

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
  end
end
