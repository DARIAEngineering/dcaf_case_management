require 'test_helper'

# Tests for the clinics controller
class ClinicsControllerTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user, role: :admin
    sign_in @user
  end

  describe 'index' do
    it 'should render if admin' do
      get clinics_path
      assert_response :success
    end

    it 'should render json' do
      get clinics_path, xhr: true
      assert_response :success
    end
  end

  describe 'create' do
    before { @new_clinic = attributes_for :clinic }

    it 'should redirect if user is not admin' do
      User.roles.keys.reject { |role| role == 'admin' }.each do |role|
        @user.update role: role

        assert_no_difference 'Clinic.count' do
          post clinics_path, params: { clinic: @new_clinic }
        end
        assert_redirected_to root_path
      end
    end

    it 'should create if fields are there' do
      assert_difference 'Clinic.count', 1 do
        post clinics_path, params: { clinic: @new_clinic }
      end
      assert_redirected_to clinics_path
    end

    it 'should fail if fields not there' do
      @new_clinic[:street_address] = ''
      assert_no_difference 'Clinic.count' do
        post clinics_path, params: { clinic: @new_clinic }
      end
    end
  end

  describe 'new' do
    it 'should redirect if not admin' do
      User.roles.keys.reject { |role| role == 'admin' }.each do |role|
        @user.update role: role
        get new_clinic_path
        assert_redirected_to root_path
      end
    end

    it 'should render' do
      @user.update role: :admin
      get new_clinic_path
      assert_response :success
    end
  end

  describe 'edit' do
    before { @clinic = create :clinic }

    it 'should redirect if not admin' do
      User.roles.keys.reject { |role| role == 'admin' }.each do |role|
        @user.update role: role
        get edit_clinic_path @clinic
        assert_redirected_to root_path
      end
    end

    it 'should render' do
      @user.update role: :admin
      get edit_clinic_path @clinic
      assert_response :success
    end
  end

  describe 'update' do
    before do
      @clinic = create :clinic
      @clinic_attrs = attributes_for :clinic, name: 'Metallica'
    end

    it 'should redirect if not admin' do
      User.roles.keys.reject { |role| role == 'admin' }.each do |role|
        @user.update role: role
        patch clinic_path(@clinic), params: { clinic: @clinic_attrs }
        @clinic.reload
        refute_equal 'Metallica', @clinic.name
        assert_redirected_to root_path
      end
    end

    it 'should update the clinic record' do
      patch clinic_path(@clinic), params: { clinic: @clinic_attrs }
      @clinic.reload
      assert_equal 'Metallica', @clinic.name
      assert_redirected_to clinics_path
    end

    it 'should not update the clinic record if the payload is bad' do
      @clinic_attrs[:name] = nil

      patch clinic_path(@clinic), params: { clinic: @clinic_attrs }
      @clinic.reload
      refute_equal 'Metallica', @clinic.name
      assert_response :success
    end
  end

  describe 'verify_availability' do
    before { @clinic = create :clinic }

    it 'should allow admin to verify' do
      @user.update role: :admin
      post verify_availability_clinic_path(@clinic), params: { availability_notes: 'Checked' }
      assert_response :redirect
      @clinic.reload
      assert_not_nil @clinic.availability_verified_at
    end

    it 'should allow case manager to verify' do
      @user.update role: :cm
      post verify_availability_clinic_path(@clinic), params: { availability_notes: 'Called' }
      assert_response :redirect
      @clinic.reload
      assert_not_nil @clinic.availability_verified_at
    end

    it 'should reject data volunteer from verifying' do
      @user.update role: :data_volunteer
      post verify_availability_clinic_path(@clinic)
      assert_redirected_to root_path
      @clinic.reload
      assert_nil @clinic.availability_verified_at
    end

    it 'should store availability notes from params' do
      @user.update role: :admin
      post verify_availability_clinic_path(@clinic), params: { availability_notes: 'Called clinic' }
      @clinic.reload
      assert_equal 'Called clinic', @clinic.availability_notes
    end

    it 'should record the verifying user' do
      @user.update role: :cm
      post verify_availability_clinic_path(@clinic), params: { availability_notes: 'Confirmed' }
      @clinic.reload
      assert_equal @user.id, @clinic.availability_verified_by_id
    end

    it 'should not allow unauthenticated access' do
      delete destroy_user_session_path
      post verify_availability_clinic_path(@clinic)
      assert_response :redirect
      @clinic.reload
      assert_nil @clinic.availability_verified_at
    end
  end
end
