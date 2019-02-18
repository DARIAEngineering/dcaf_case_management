require 'test_helper'

class PracticalSupportsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get practical_supports_create_url
    assert_response :success
  end

  test "should get update" do
    get practical_supports_update_url
    assert_response :success
  end

  test "should get destroy" do
    get practical_supports_destroy_url
    assert_response :success
  end

end
