require 'test_helper'

class CallsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @user = build :user
    sign_in @user
    @case = create :case
  end

  describe 'create method' do
    before do
      @call = attributes_for :call
    end

    it 'should create and save a new call' do
      assert_difference 'Case.find(@case).calls.count', 1 do
        post :create, call: @call, id: @case
      end
      assert_response :redirect
    end

    it 'should redirect to the root path afterwards' do
      post :create, call: @call, id: @case
      assert_redirected_to root_path
    end

    it 'should not save if status is blank for some reason' do
      @call[:status] = nil
      assert_no_difference 'Case.find(@case).calls.count' do
        post :create, call: @call, id: @case
      end
    end

    # TODO set up strong parameters for calls controller
    it 'should reject other attributes besides status' do
      assert_no_difference 'Case.find(@case).calls.count' do 
        @call[:other] = "extraneous attribute"
        post :create, call: @call, id: @case
      end
    end
  end
end
