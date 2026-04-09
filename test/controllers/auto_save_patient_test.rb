require 'test_helper'

class AutoSavePatientTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    @line = create :line
    @patient = create :patient, name: 'Original Name'
    sign_in @user
    choose_line @line
  end

  describe 'PATCH patient (autosave)' do
    it 'should update patient via PATCH' do
      patch patient_path(@patient), params: {
        patient: { name: 'Auto-Saved Name' }
      }
      assert_response :redirect
      @patient.reload
      assert_equal 'Auto-Saved Name', @patient.name
    end

    it 'should reject update without authentication' do
      delete destroy_user_session_path
      patch patient_path(@patient), params: {
        patient: { name: 'Unauthorized' }
      }
      assert_response :redirect
      @patient.reload
      refute_equal 'Unauthorized', @patient.name
    end

    it 'should render edit page with patient form' do
      get edit_patient_path(@patient)
      assert_response :success
      assert_select '#patient_dashboard_form'
    end
  end
end
