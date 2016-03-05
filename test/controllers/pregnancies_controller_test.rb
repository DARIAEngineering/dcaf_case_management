require 'test_helper'

class PregnanciesControllerTest < ActionController::TestCase
  def setup
    @user = create :user
    sign_in @user
  end

  it "should get index" do
    get :index
    assert_response :success
  end
end
