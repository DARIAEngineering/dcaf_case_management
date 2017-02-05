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
    @clinic = create :clinic, name: 'Sample Clinic 1', patient: @patient
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

  describe 'update method' do
    before do
      @date = 5.days.from_now.to_date
      @payload = {
        appointment_date: @date.strftime('%Y-%m-%d'), name: 'Susie Everyteen 2',
        pregnancy: { resolved_without_dcaf: true },
        clinic: { name: 'Sample Clinic 2', id: @clinic.id }
      }

      patch :update, id: @patient, patient: @payload
      @patient.reload
    end

    it 'should respond success on completion' do
      assert_response :success
    end

    it 'should respond bad request on failure' do
      @payload[:primary_phone] = nil
      patch :update, id: @patient, patient: @payload
      assert_response :bad_request
    end

    it 'should update pregnancy fields' do
      assert_equal @date, @patient.appointment_date
    end

    it 'should update clinic fields' do
      assert_equal 'Sample Clinic 2', @patient.clinic.name
    end

    it 'should update patient fields' do
      assert_equal 'Susie Everyteen 2', @patient.name
    end

    it 'should redirect if record does not exist' do
      patch :update, id: 'notanactualid', patient: @payload
      assert_redirected_to root_path
    end
  end

  #confirm get :data_entry returns a success code
  describe 'data_entry method' do
    it 'should respond success on completion' do
      get :data_entry
      assert_response :success
    end
  end

  # confirm sending a 'post' with a payload results in a new patient
  describe 'data_entry_create method' do
    before do
      @test_patient = attributes_for :patient, name: 'Test Patient'
      @test_patient[:pregnancy] = attributes_for :pregnancy
    end

    it 'should create and save a new patient' do
      assert_difference 'Patient.count', 1 do
        post :data_entry_create, patient: @test_patient
      end
    end

    it 'should redirect to edit_patient_path afterwards' do
      post :data_entry_create, patient: @test_patient
      @created_patient = Patient.find_by(name: 'Test Patient')
      assert_redirected_to edit_patient_path @created_patient
    end

    it 'should fail to save if name is blank' do
      @test_patient[:name] = ''
      assert_no_difference 'Patient.count' do
        post :data_entry_create, patient: @test_patient
      end
      assert_no_difference 'Pregnancy.count' do
        post :data_entry_create, patient: @test_patient
      end
    end

    it 'should fail to save if primary phone is blank' do
      @test_patient[:primary_phone] = ''
      assert_no_difference 'Patient.count' do
        post :data_entry_create, patient: @test_patient
      end
      assert_no_difference 'Pregnancy.count' do
        post :data_entry_create, patient: @test_patient
      end
    end

    it 'should create an associated pregnancy object' do
      post :data_entry_create, patient: @test_patient
      assert_not_nil Patient.find_by(name: 'Test Patient').pregnancy
    end
  end
end
