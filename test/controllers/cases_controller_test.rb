require 'test_helper'

class CasesControllerTest < ActionController::TestCase
  it "should get index" do
    get :index
    assert_response :success
  end
end
