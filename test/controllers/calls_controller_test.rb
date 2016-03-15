require 'test_helper'

class CallsControllerTest < ActionController::TestCase
  def setup
    @user = build :user
    sign_in @user
    @pregnancy = create :pregnancy
  end

  describe 'create method' do
    before do
      @call = attributes_for :call
    end

    it 'should create and save a new call' do
      assert_difference 'Pregnancy.find(@pregnancy).calls.count', 1 do
        post :create, call: @call, id: @pregnancy
      end
      assert_response :redirect
    end

    it 'should respond success if patient is not reached' do
      call  = attributes_for :call, status: "Left voicemail"
      post :create, call: call, id: @pregnancy, format: :js
      assert_response :success
    end

    it 'should redirect to the edit pregnancy path if patient is reached' do
      post :create, call: @call, id: @pregnancy
      assert_redirected_to edit_pregnancy_path(@pregnancy)
    end

    it 'should not save if status is blank for some reason' do
      @call[:status] = nil
      assert_no_difference 'Pregnancy.find(@pregnancy).calls.count' do
        post :create, call: @call, id: @pregnancy
      end
    end
  end
end
