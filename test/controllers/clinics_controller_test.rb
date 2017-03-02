require 'test_helper'

class ClinicsControllerTest < ActionController::TestCase
  before do
    @user = create :user, role: :admin
    sign_in @user
  end

  describe 'index' do
    it 'should redirect if not admin' do
      @user.update role: :cm
      get :index
      assert_response :redirect
    end

    it 'should render if admin' do
      get :index
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
        post :create, clinic: @new_clinic
      end
      assert_redirected_to clinics_path
    end

    it 'should fail if fields not there' do
      @new_clinic[:address] = ''
      assert_no_difference 'Clinic.count' do
        post :create, clinic: @new_clinic
      end
    end
  end

  describe 'new' do
    it 'should render' do
      get :new
      assert_response :success
    end
  end
end
