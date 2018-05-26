require 'test_helper'

class CallListsControllerTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user, role: 'admin'
    @user_2 = create :user, role: 'cm', name: 'Billy Everyteen'
    @patient_1 = create :patient, name: 'Susan Everyteen'
    @patient_2 = create :patient, name: 'Yolo Goat'

    sign_in @user
  end

  describe 'add_patient method' do
    before do
      patch add_patient_path(@patient_1), xhr: true
    end

    it 'should respond successfully' do
      assert_response :success
    end

    it 'should add a patient to a users call list' do
      @user.reload
      assert_equal @user.patients.count, 1
      assert_difference '@user.patients.count', 1 do
        patch add_patient_path(@patient_2), xhr: true
        @user.reload
      end
      assert_equal @user.patients.count, 2
    end

    it 'should not adjust the count if a patient is already in the list' do
      assert_no_difference '@user.patients.count' do
        patch add_patient_path(@patient_1), xhr: true
      end
    end

    it 'should should return not found on sketch ids' do
      patch add_patient_path('nopatient'), xhr: true
      assert_response :not_found
    end
  end

  describe 'remove_patient method' do
    before do
      patch add_patient_path(@patient_1), xhr: true
      patch add_patient_path(@patient_2), xhr: true
      patch remove_patient_path(@patient_1), xhr: true
      @user.reload
    end

    it 'should respond successfully' do
      assert_response :success
    end

    it 'should remove a patient' do
      assert_difference '@user.patients.count', -1 do
        patch remove_patient_path(@patient_2), xhr: true
        @user.reload
      end
    end

    it 'should do nothing if the patient is not currently in the call list' do
      assert_no_difference '@user.patients.count' do
        patch remove_patient_path(@patient_1), xhr: true
      end
      assert_response :success
    end

    it 'should should return bad request on sketch ids' do
      patch remove_patient_path('whatever'), xhr: true
      assert_response :not_found
    end
  end

  describe 'clear_current_user_call_list method' do
    before do
      patch add_patient_path(@patient_1), xhr: true
      patch add_patient_path(@patient_2), xhr: true
      @user.reload
    end

    it 'should respond successfully' do
      patch clear_current_user_call_list_path, xhr: true
      assert_response :success
    end

    it 'should clear all patients for a user' do
      assert_difference '@user.patients.count', -2 do
        patch clear_current_user_call_list_path, xhr: true
        @user.reload
      end
    end

    it 'should not destroy patients' do
      assert_no_difference 'Patient.count' do
        patch clear_current_user_call_list_path, xhr: true
      end
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
end
