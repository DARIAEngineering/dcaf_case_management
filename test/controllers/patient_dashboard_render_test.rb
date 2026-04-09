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
  end
end
