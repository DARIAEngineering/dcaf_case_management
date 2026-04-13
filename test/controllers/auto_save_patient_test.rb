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

    it 'should update multiple fields in a single PATCH' do
      patch patient_path(@patient), params: {
        patient: { name: 'Updated Name', city: 'New City' }
      }
      @patient.reload
      assert_equal 'Updated Name', @patient.name
      assert_equal 'New City', @patient.city
    end

    it 'should not update patient from a different tenant' do
      other_fund = create :fund
      other_patient = nil
      ActsAsTenant.with_tenant(other_fund) do
        other_patient = create :patient, name: 'Other Tenant'
      end
      assert_raises(ActiveRecord::RecordNotFound) do
        patch patient_path(other_patient), params: {
          patient: { name: 'Cross Tenant' }
        }
      end
    end

    it 'should respond to JSON format requests' do
      patch patient_path(@patient, format: :json), params: {
        patient: { name: 'JSON Save' }
      }
      assert_response :success
      @patient.reload
      assert_equal 'JSON Save', @patient.name
    end

    it 'should render autosave data attributes on the form' do
      get edit_patient_path(@patient)
      assert_response :success
      assert_select 'form[data-controller="autosave"]'
      assert_select 'form[data-autosave-url-value]'
      assert_select '[data-autosave-target="indicator"]'
    end

    it 'should not change updated_at when no fields actually change' do
      original_updated_at = @patient.updated_at
      patch patient_path(@patient), params: {
        patient: { name: @patient.name }
      }
      @patient.reload
      assert_equal original_updated_at.to_i, @patient.updated_at.to_i
    end
  end
end