require 'test_helper'

class CallsControllerTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    sign_in @user
    @patient = create :patient
  end

  describe 'new method' do
    it 'should respond successfully' do
      get new_patient_call_path(@patient), xhr: true
      assert_response :success
    end
  end

  describe 'create method' do
    before do
      with_versioning do
        @call = attributes_for :call, status: :reached_patient
        post patient_calls_path(@patient), params: { call: @call }, xhr: true
      end
    end

    it 'should create and save a new call' do
      assert_difference 'Patient.find(@patient.id).calls.count', 1 do
        post patient_calls_path(@patient), params: { call: @call }, xhr: true
      end
    end

    it 'should respond success if patient is not reached' do
      [:left_voicemail, :couldnt_reach_patient].each do |status|
        call = attributes_for :call, status: status
        post patient_calls_path(@patient), params: { call: call }, xhr: true
        assert_response :success
      end
    end

    it 'should redirect to the edit patient path if patient is reached' do
      assert_redirected_to edit_patient_path(@patient)
    end

    it 'should not save and flash an error if status is blank or bad' do
      [nil, 'not a real status'].each do |bad_status|
        call = attributes_for :call, status: bad_status
        assert_no_difference 'Patient.find(@patient.id).calls.count' do
          post patient_calls_path(@patient), params: { call: call }, xhr: true
        end
        assert_response :bad_request
      end
    end

    it 'should log the creating user' do
      assert_equal Patient.find(@patient.id).calls.last.created_by,
                   @user
    end
  end

  describe 'destroy method' do
    it 'should destroy a call' do
      with_versioning do
        PaperTrail.request(whodunnit: @user.id) do
          @patient.calls.create attributes_for(:call)
        end
      end

      call = @patient.calls.first
      assert_difference 'Patient.find(@patient.id).calls.count', -1 do
        delete patient_call_path(@patient, call), params: { id: call.id },
                                                  xhr: true
      end
    end

    it 'should not allow user to destroy calls created by others' do
      with_versioning do
        PaperTrail.request(whodunnit: create(:user)) do
          @patient.calls.create attributes_for(:call)
        end
      end

      call = @patient.calls.first
      assert_no_difference 'Patient.find(@patient.id).calls.count' do
        delete patient_call_path(@patient, call), params: { id: call.id },
                                                  xhr: true
      end
      assert_response :forbidden
    end

    it 'should not allow user to destroy old calls' do
      with_versioning do
        @patient.calls.create attributes_for(:call, updated_at: Time.zone.now - 1.day)
      end
      call = @patient.calls.first

      assert_no_difference 'Patient.find(@patient.id).calls.count' do
        delete patient_call_path(@patient, call), params: { id: call.id },
                                                  xhr: true
      end
      assert_response :forbidden
    end
  end
end
