require "test_helper"

class FundsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @fund = funds(:one)
  end

  # TODO: may need to use current_tenant
  test "should show fund" do
    get fund_url(@fund)
    assert_response :success
  end

  test "should get edit" do
    get edit_fund_url(@fund)
    assert_response :success
  end

  test "should update fund" do
    patch fund_url(@fund), params: { fund: {  } }
    assert_redirected_to fund_url(@fund)
  end
end
