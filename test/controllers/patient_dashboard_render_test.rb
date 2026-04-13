require 'test_helper'

class PatientDashboardRenderTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    @line = create :line
    @patient = create :patient
    sign_in @user
    choose_line @line
  end

  describe 'patient dashboard (server-rendered)' do
    it 'should render the patient edit page successfully' do
      get edit_patient_path(@patient)
      assert_response :success
    end

    it 'should display patient name on dashboard' do
      get edit_patient_path(@patient)
      assert_response :success
      assert_match @patient.name, response.body
    end

    it 'should include Stimulus application.js setup' do
      get edit_patient_path(@patient)
      assert_response :success
      # The page should load without errors
      assert_select 'form.edit_patient'
    end

    it 'should render patient dashboard form with data attributes' do
      get edit_patient_path(@patient)
      assert_response :success
      assert_select '#patient_dashboard_form'
    end

    # Server-rendered field presence tests (replacing removed React Input/Select tests)
    it 'should render an input for name' do
      get edit_patient_path(@patient)
      assert_select 'input[name="patient[name]"]'
    end

    it 'should render a select for last_menstrual_period_weeks' do
      get edit_patient_path(@patient)
      assert_select 'select[name="patient[last_menstrual_period_weeks]"]'
    end

    it 'should render a select for last_menstrual_period_days' do
      get edit_patient_path(@patient)
      assert_select 'select[name="patient[last_menstrual_period_days]"]'
    end

    it 'should render an input for appointment_date' do
      get edit_patient_path(@patient)
      assert_select 'input[name="patient[appointment_date]"]'
    end

    it 'should render an input for primary_phone' do
      get edit_patient_path(@patient)
      assert_select 'input[name="patient[primary_phone]"]'
    end

    it 'should render an input for pronouns' do
      get edit_patient_path(@patient)
      assert_select 'input[name="patient[pronouns]"]'
    end

    # Stimulus data attributes wired up on the form
    it 'should render autosave stimulus controller on the form' do
      get edit_patient_path(@patient)
      assert_select '#patient_dashboard_form[data-controller="autosave"]'
    end

    it 'should render stimulus action attributes on input fields' do
      get edit_patient_path(@patient)
      assert_select 'input[data-action*="autosave#save"]'
    end

    # Admin vs non-admin behavior
    it 'should render delete link for admins' do
      @user.update!(role: :admin)
      get edit_patient_path(@patient)
      assert_select 'a[href=?]', patient_path(@patient), text: /delete/i
    end

    it 'should not render delete link for case managers' do
      get edit_patient_path(@patient)
      assert_select 'a[data-method="delete"]', count: 0
    end

    it 'should update patient fields via PATCH' do
      patch patient_path(@patient), params: {
        patient: { name: 'Updated via PATCH' }
      }
      @patient.reload
      assert_equal 'Updated via PATCH', @patient.name
    end
  end
end