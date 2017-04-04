require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    sign_in @user
    @patient_1 = create :patient, name: 'Susan Everyteen'
    create :pregnancy, patient: @patient_1
    @patient_2 = create :patient, name: 'Yolo Goat'
    create :pregnancy, patient: @patient_2
  end

  describe 'create method' do
    it 'should raise if user is not admin' do
      @user.role = :cm
      @user.save!
      assert_raise RuntimeError, 'Permission Denied' do
        post users_path, params: { user: attributes_for(:user) }
      end
    end
  end

  describe 'index method' do
    it 'should redirect if user is not admin' do
      User::ROLE.reject { |role| role == :admin }.each do |role|
        @user.update role: role
        get users_path
        assert_response :redirect
      end
    end

    it 'should let admin access the route' do
      @user.role = :admin
      @user.save!
      get users_path
      assert_response :success
    end
  end

  describe 'add_patient method' do
    before do
      patch add_patient_path(@user, @patient_1), xhr: true
    end

    it 'should respond successfully' do
      assert_response :success
    end

    it 'should add a patient to a users call list' do
      @user.reload
      assert_equal @user.patients.count, 1
      assert_difference '@user.patients.count', 1 do
        patch add_patient_path(@user, @patient_2), xhr: true
        @user.reload
      end
      assert_equal @user.patients.count, 2
    end

    it 'should not adjust the count if a patient is already in the list' do
      assert_no_difference '@user.patients.count' do
        patch add_patient_path(@user, @patient_1), xhr: true
      end
    end

    it 'should should return bad request on sketch ids' do
      patch add_patient_path(@user, 'nopatient'), xhr: true
      assert_response :bad_request
    end
  end

  describe 'remove_patient method' do
    before do
      patch add_patient_path(@user, @patient_1), xhr: true
      patch add_patient_path(@user, @patient_2), xhr: true
      patch remove_patient_path(@user, @patient_1), xhr: true
      @user.reload
    end

    it 'should respond successfully' do
      assert_response :success
    end

    it 'should remove a patient' do
      assert_difference '@user.patients.count', -1 do
        patch remove_patient_path(@user, @patient_2), xhr: true
        @user.reload
      end
    end

    it 'should do nothing if the patient is not currently in the call list' do
      assert_no_difference '@user.patients.count' do
        patch remove_patient_path(@user, @patient_1), xhr: true
      end
      assert_response :success
    end

    it 'should should return bad request on sketch ids' do
      patch remove_patient_path(@user, 'whatever'), xhr: true
      assert_response :bad_request
    end
  end

  describe 'reorder call list' do
    before do
      @ids = []
      4.times { @ids << create(:patient)._id.to_s }
      @ids.shuffle!

      patch reorder_call_list_path, params: { order: @ids }, xhr: true
      @user.reload
    end

    it 'should respond success' do
      assert_response :success
    end

    it 'should populate the user call order field' do
      assert_not_nil @user.call_order
      assert_equal @ids, @user.call_order
    end
  end

  it 'should be the devise controller' do
    assert :devise_controller?
  end
end
