require "test_helper"

# Tests for reports controller
class ReportsControllerTest < ActionDispatch::IntegrationTest
  describe 'index' do
    it 'should render if admin' do
      sign_in create :user, role: :admin
      get reports_path
      assert_response :success
    end

    it 'should deny if not' do
      sign_in create :user, role: :cm
      get reports_path
      assert_redirected_to root_url
    end
  end
end
