require 'test_helper'

class CallsControllerTest < ActionController::TestCase
  def setup
    @user = build :user
    sign_in @user
    @pregnancy_case = create :pregnancy_case
  end

  describe 'create method' do
    before do
      @call = attributes_for :call
    end

    it 'should create and save a new call' do
      assert_difference 'PregnancyCase.find(@pregnancy_case).calls.count', 1 do
        post :create, call: @call, id: @pregnancy_case
      end
      assert_response :redirect
    end

    it 'should redirect to the root path afterwards' do
      post :create, call: @call, id: @pregnancy_case
      assert_redirected_to root_path
    end

    it 'should not save if status is blank for some reason' do
      @call[:status] = nil
      assert_no_difference 'PregnancyCase.find(@pregnancy_case).calls.count' do
        post :create, call: @call, id: @pregnancy_case
      end
    end
  end
end
