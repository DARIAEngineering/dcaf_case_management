require 'test_helper'

class EventsControllerTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    line = create :line
    sign_in @user
    choose_line line
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
