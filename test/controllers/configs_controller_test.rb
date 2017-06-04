require 'test_helper'

class ConfigsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get configs_index_url
    assert_response :success
  end

end
