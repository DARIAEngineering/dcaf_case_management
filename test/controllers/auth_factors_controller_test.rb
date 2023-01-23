require 'test_helper'

# Tests for the auth factors controller
class AuthFactorsControllerTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user, role: :admin
    sign_in @user
  end

  describe 'new' do
    it 'should render' do
      get new_auth_factor_path

      assert_redirected_to build_auth_factor_path(AuthFactor.form_steps.first)
    end

    it 'should create unregistered auth factor' do
      assert_difference('AuthFactor.count', 1) do
        get new_auth_factor_path
      end

      assert session.key?(:auth_factor_id)

      new_auth_factor = AuthFactor.find(session[:auth_factor_id])
      assert_not new_auth_factor.registration_complete
      assert_not new_auth_factor.enabled
    end
  end

  describe 'destroy' do
    before do
      @user.auth_factors.create attributes_for(:auth_factor, :registration_complete)
      @auth_factor = @user.auth_factors.first
    end

    it 'should destroy an auth factor record' do
      assert_difference('AuthFactor.count', -1) do
        delete auth_factor_path(@auth_factor)
      end

      assert_redirected_to edit_user_registration_path
    end
  end
end
