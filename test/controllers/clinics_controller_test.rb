require 'test_helper'

class ClinicsControllerTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user, role: :admin
    sign_in @user
  end

  describe 'index' do
    it 'should redirect if not admin' do
      User::ROLE.reject { |role| role == :admin }.each do |role|
        @user.update role: role
        get clinics_path
        assert_response :redirect
      end
    end

    it 'should render if admin' do
      get clinics_path
      assert_response :success
    end
  end

  describe 'create' do
    before { @new_clinic = attributes_for :clinic }

    # it 'should raise if user is not admin' do # TODO
    #   @user.role = :cm
    #   @user.save!
    #   assert_raise RuntimeError, 'Permission Denied' do
    #     post :create
    #   end
    # end

    it 'should create if fields are there' do
      assert_difference 'Clinic.count', 1 do
        post clinics_path, params: { clinic: @new_clinic }
      end
      assert_response :redirect
      # assert_redirected_to clinics_path
    end

    it 'should fail if fields not there' do
      @new_clinic[:street_address] = ''
      assert_no_difference 'Clinic.count' do
        post clinics_path, params: { clinic: @new_clinic }
      end
    end
  end

  describe 'new' do
    it 'should render' do
      get new_clinic_path
      assert_response :success
    end
  end

  describe 'edit' do
    before { @clinic = create :clinic }

    it 'should render' do
      get edit_clinic_path(@clinic)
      assert_response :success
    end
  end

  # TODO
  # describe 'update' do
  # end
end
