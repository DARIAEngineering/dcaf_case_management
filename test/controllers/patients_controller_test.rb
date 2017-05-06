require 'test_helper'

class PatientsControllerTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    sign_in @user
    @patient = create :patient,
                      name: 'Susie Everyteen',
                      primary_phone: '123-456-7890',
                      other_phone: '333-444-5555'
    @clinic = create :clinic
  end

  describe 'create method' do
    before do
      @new_patient = attributes_for :patient, name: 'Test Patient'
    end

    it 'should create and save a new patient' do
      assert_difference 'Patient.count', 1 do
        post patients_path, params: { patient: @new_patient }
      end
    end

    it 'should redirect to the root path afterwards' do
      post patients_path, params: { patient: @new_patient }
      assert_redirected_to root_path
    end

    it 'should fail to save if name is blank' do
      @new_patient[:name] = ''
      assert_no_difference 'Patient.count' do
        post patients_path, params: { patient: @new_patient }
      end
    end

    it 'should fail to save if primary phone is blank' do
      @new_patient[:primary_phone] = ''
      assert_no_difference 'Patient.count' do
        post patients_path, params: { patient: @new_patient }
      end
    end

    it 'should create an associated fulfillment object' do
      post patients_path, params: { patient: @new_patient }
      assert_not_nil Patient.find_by(name: 'Test Patient').fulfillment
    end
  end

  describe 'edit method' do
    before do
      get edit_patient_path(@patient)
    end

    it 'should get edit' do
      assert_response :success
    end

    it 'should redirect to root on a bad id' do
      get edit_patient_path('notanid')
      assert_redirected_to root_path
    end

    it 'should contain the current record' do
      assert_match /Susie Everyteen/, response.body
      assert_match /123-456-7890/, response.body
      assert_match /Friendly Clinic/, response.body
    end
  end

  describe 'update method' do
    before do
      @date = 5.days.from_now.to_date
      @payload = {
        appointment_date: @date.strftime('%Y-%m-%d'),
        name: 'Susie Everyteen 2',
        resolved_without_dcaf: true
      }

      patch patient_path(@patient), params: { patient: @payload }
      @patient.reload
    end

    it 'should respond success on completion' do
      assert_response :success
    end

    it 'should respond internal server error on failure' do
      @payload[:primary_phone] = nil
      patch patient_path(@patient), params: { patient: @payload }
      assert_response :internal_server_error
    end

    it 'should update patient fields' do
      assert_equal 'Susie Everyteen 2', @patient.name
    end

    it 'should redirect if record does not exist' do
      patch patient_path('notanactualid'), params: { patient: @payload }
      assert_redirected_to root_path
    end
  end

  #confirm get :data_entry returns a success code
  describe 'data_entry method' do
    it 'should respond success on completion' do
      get data_entry_path
      assert_response :success
    end
  end

  describe 'download' do
    it 'should not download a pdf with no case manager name' do
      get generate_pledge_patient_path(@patient), params: { case_manager_name: '' }
      assert_redirected_to edit_patient_path(@patient)
    end

    it 'should download a pdf' do
      pledge_generator_mock = Minitest::Mock.new
      pdf_mock_result = Minitest::Mock.new
      pledge_generator_mock.expect(:generate_pledge_pdf, pdf_mock_result)
      pdf_mock_result.expect :render, "mow"
      assert_nil @patient.pledge_generated_at
      PledgeFormGenerator.stub(:new, pledge_generator_mock) do
        get generate_pledge_patient_path(@patient), params: { case_manager_name: 'somebody' }
      end

      refute_nil @patient.reload.pledge_generated_at
      assert_response :success
    end
  end

  # confirm sending a 'post' with a payload results in a new patient
  describe 'data_entry_create method' do
    before do
      @test_patient = attributes_for :patient, name: 'Test Patient'
    end

    it 'should create and save a new patient' do
      assert_difference 'Patient.count', 1 do
        post data_entry_create_path, params: { patient: @test_patient }
      end
    end

    it 'should redirect to edit_patient_path afterwards' do
      post data_entry_create_path, params: { patient: @test_patient }
      @created_patient = Patient.find_by(name: 'Test Patient')
      assert_redirected_to edit_patient_path @created_patient
    end

    it 'should fail to save if name is blank' do
      @test_patient[:name] = ''
      assert_no_difference 'Patient.count' do
        post data_entry_create_path, params: { patient: @test_patient }
      end
    end

    it 'should fail to save if primary phone is blank' do
      @test_patient[:primary_phone] = ''
      assert_no_difference 'Patient.count' do
        post data_entry_create_path, params: { patient: @test_patient }
      end
    end

    it 'should create an associated fulfillment object' do
      post data_entry_create_path, params: { patient: @test_patient }
      assert_not_nil Patient.find_by(name: 'Test Patient').fulfillment
    end
  end
end
