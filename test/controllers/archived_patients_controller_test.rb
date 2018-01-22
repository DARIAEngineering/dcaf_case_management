require 'test_helper'

class ArchivedPatientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @archived_patient = archived_patients(:one)
  end

  test "should get index" do
    get archived_patients_url
    assert_response :success
  end

  test "should get new" do
    get new_archived_patient_url
    assert_response :success
  end

  test "should create archived_patient" do
    assert_difference('ArchivedPatient.count') do
      post archived_patients_url, params: { archived_patient: { had_other_contact: @archived_patient.had_other_contact } }
    end

    assert_redirected_to archived_patient_url(ArchivedPatient.last)
  end

  test "should show archived_patient" do
    get archived_patient_url(@archived_patient)
    assert_response :success
  end

  test "should get edit" do
    get edit_archived_patient_url(@archived_patient)
    assert_response :success
  end

  test "should update archived_patient" do
    patch archived_patient_url(@archived_patient), params: { archived_patient: { had_other_contact: @archived_patient.had_other_contact } }
    assert_redirected_to archived_patient_url(@archived_patient)
  end

  test "should destroy archived_patient" do
    assert_difference('ArchivedPatient.count', -1) do
      delete archived_patient_url(@archived_patient)
    end

    assert_redirected_to archived_patients_url
  end
end
