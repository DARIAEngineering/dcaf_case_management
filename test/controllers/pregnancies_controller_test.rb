require 'test_helper'

class PregnanciesControllerTest < ActionController::TestCase
  it "should get index" do
    get :index
    assert_response :success
  end
end
