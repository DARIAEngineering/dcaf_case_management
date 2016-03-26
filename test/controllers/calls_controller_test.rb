require 'test_helper'

class CallsControllerTest < ActionController::TestCase
  before do
    @user = create :user
    sign_in @user
    @pregnancy = create :pregnancy
  end

  describe 'create method' do
    before do
      @call = attributes_for :call
      post :create, call: @call, id: @pregnancy, format: :js
    end

    it 'should create and save a new call' do
      assert_difference 'Pregnancy.find(@pregnancy).calls.count', 1 do
        post :create, call: @call, id: @pregnancy, format: :js
      end
    end

    it 'should respond success if patient is not reached' do
      call = attributes_for :call, status: 'Left voicemail'
      post :create, call: call, id: @pregnancy, format: :js
      assert_response :success
    end

    it 'should redirect to the edit pregnancy path if patient is reached' do
      post :create, call: @call, id: @pregnancy, format: :js
      assert_redirected_to edit_pregnancy_path(@pregnancy)
    end

    it 'should render create.js.erb if patient is not reached or if could not reach' do
      ['Left voicemail', "Couldn't reach patient"].each do |status|
        @call[:status] = status
        post :create, call: @call, id: @pregnancy, format: :js
        assert_template 'calls/create'
      end
    end

    it 'should not save and flash an error if status is blank or bad for some reason' do
      [nil, 'not a real status'].each do |bad_status|
        @call[:status] = bad_status
        assert_no_difference 'Pregnancy.find(@pregnancy).calls.count' do
          post :create, call: @call, id: @pregnancy, format: :js
        end
        assert_redirected_to root_path
      end
    end

    it 'should log the creating user' do
      assert_equal Pregnancy.find(@pregnancy).calls.last.creating_user_id, @user.id.to_s
    end
  end
end
