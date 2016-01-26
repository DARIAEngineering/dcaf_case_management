require 'test_helper'

class CasesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  it "should get index" do
    get :index
    assert_response :success
  end
end
