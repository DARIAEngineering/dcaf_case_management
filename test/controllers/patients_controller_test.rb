require 'test_helper'

class PatientsControllerTest < ActionController::TestCase
  before do
    @user = create :user
    sign_in @user
    @patient = create :patient,
                      name: 'Susie Everyteen',
                      primary_phone: '123-456-7890',
                      other_phone: '333-444-5555'
    @pregnancy = create :pregnancy, patient: @patient
    @clinic = create :clinic, name: 'Sample Clinic 1', pregnancy: @pregnancy
  end

  describe 'create method' do
    before do
      @new_patient = attributes_for :patient, name: 'Test Patient'
      @new_patient[:pregnancy] = attributes_for :pregnancy
    end

    it 'should create and save a new patient' do
      assert_difference 'Patient.count', 1 do
        post :create, patient: @new_patient
      end
    end

    it 'should redirect to the root path afterwards' do
      post :create, patient: @new_patient
      assert_redirected_to root_path
    end

    it 'should fail to save if name is blank' do
      @new_patient[:name] = ''
      assert_no_difference 'Patient.count' do
        post :create, patient: @new_patient
      end
      assert_no_difference 'Pregnancy.count' do
        post :create, patient: @new_patient
      end
    end

    it 'should fail to save if primary phone is blank' do
      @new_patient[:primary_phone] = ''
      assert_no_difference 'Patient.count' do
        post :create, patient: @new_patient
      end
      assert_no_difference 'Pregnancy.count' do
        post :create, patient: @new_patient
      end
    end

    it 'should create an associated pregnancy object' do
      post :create, patient: @new_patient
      assert_not_nil Patient.find_by(name: 'Test Patient').pregnancy
    end
  end

  describe 'edit method' do
    before do
      get :edit, id: @patient
    end

    it 'should get edit' do
      assert_response :success
    end

    it 'should redirect to root on a bad id' do
      get :edit, id: 'notanid'
      assert_redirected_to root_path
    end

    it 'should contain the current record' do
      assert_match /Susie Everyteen/, response.body
      assert_match /123-456-7890/, response.body
      assert_match /Sample Clinic 1/, response.body
    end

    it 'should not die if clinic is nil' do
      @clinic.destroy

      get :edit, id: @patient
      assert_response :success
    end
  end

  # describe 'update method' do
  #   before do
  #     @payload = {
  #       appointment_date: '2016-09-04', name: 'Susie Everyteen 2',
  #       pregnancy: { resolved_without_dcaf: true },
  #       clinic: { name: 'Clinic A', id: @clinic.id }
  #     }

  #     patch :update, id: @pregnancy, pregnancy: @payload
  #     @pregnancy.reload
  #   end

  #   it 'should respond success on completion' do
  #     assert_response :success
  #   end

  #   it 'should respond bad request on failure' do
  #     @payload[:patient][:primary_phone] = nil
  #     patch :update, id: @pregnancy, pregnancy: @payload
  #     assert_response :bad_request
  #   end

  #   it 'should update pregnancy fields' do
  #     assert_equal @pregnancy.appointment_date, '2016-09-04'.to_date
  #   end

  #   it 'should update clinic fields' do
  #     assert_equal @pregnancy.clinic.name, 'Clinic A'
  #   end

  #   it 'should update patient fields' do
  #     assert_equal @pregnancy.patient.name, 'Susie Everyteen 2'
  #   end

  #   it 'should redirect if record does not exist' do
  #     patch :update, id: 'notanactualid', pregnancy: @payload
  #     assert_redirected_to root_path
  #   end
  # end
end
