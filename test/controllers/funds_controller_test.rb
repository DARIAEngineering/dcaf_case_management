require "test_helper"

class FundsControllerTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user, role: :admin
    sign_in @user
    @fund = create :fund
  end

  describe 'show' do
    it 'should render if admin' do
      get fund_url(@fund)
      assert_response :success
    end

    it 'should render json' do
      get fund_url(@fund), xhr: true
      assert_response :success
    end
  end

  describe 'edit' do
    it 'should redirect if not admin' do
      User.roles.keys.reject { |role| role == 'admin' }.each do |role|
        @user.update role: role
        get edit_fund_url(@fund)
        assert_redirected_to root_path
      end
    end

    it 'should render' do
      @user.update role: :admin
      get edit_fund_url(@fund)
      assert_response :success
    end
  end

  describe 'update' do
    before do
      @phone = '555-555-5555'
      @fund_attrs = { phone: @phone }
    end

    it 'should redirect if not admin' do
      User.roles.keys.reject { |role| role == 'admin' }.each do |role|
        @user.update role: role
        patch fund_url(@fund), params: { fund: @fund_attrs }
        assert_not_equal @phone, @fund.phone
        assert_redirected_to root_path
      end
    end

    it 'should update the fund record' do
      patch fund_url(@fund), params: { fund: @fund_attrs }
      @fund.reload
      assert_equal @phone, @fund.phone
      assert_redirected_to fund_url(@fund)
    end

    it 'should not update the fund record if the payload is bad' do
      @fund_attrs[:name] = nil

      patch fund_url(@fund), params: { fund: @fund_attrs }
      @fund.reload
      assert_not_equal @phone, @fund.phone
      assert_response :unprocessable_entity
    end
  end
end
