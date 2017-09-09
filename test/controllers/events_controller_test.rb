require 'test_helper'

class EventsControllerTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    sign_in @user
    choose_line 'dc'
  end

  describe 'index method' do
    before do
      get events_path
    end

    it 'should return success' do
      assert_response :success
    end
  end
end
