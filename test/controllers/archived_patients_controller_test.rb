require 'test_helper'

class ArchivedPatientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @archived_patient = archived_patients(:one)
  end

  test "should get index" do
    get archived_patients_url
    assert_response :success
  end

  test "should show archived_patient" do
    get archived_patient_url(@archived_patient)
    assert_response :success
  end

  test "should destroy archived_patient" do
    assert_difference('ArchivedPatient.count', -1) do
      delete archived_patient_url(@archived_patient)
    end

    assert_redirected_to archived_patients_url
  end
end
