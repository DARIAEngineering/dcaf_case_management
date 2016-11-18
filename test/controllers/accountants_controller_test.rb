require 'test_helper'

class AccountantsControllerTest < ActionController::TestCase
  before do
    @user = create :user
    sign_in @user
  end

  describe 'index method' do
    it 'should return success' do
      get :index
      assert_response :success
    end
  end

  describe 'search post method' do
    it 'should return success' do
      post :search
      assert_response :success
    end
  end
end
