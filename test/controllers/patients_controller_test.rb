require 'test_helper'

class PatientsControllerTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    @admin = create :user, role: :admin
    @data_volunteer = create :user, role: :data_volunteer

    sign_in @user
    @clinic = create :clinic
    @patient = create :patient,
                      name: 'Susie Everyteen',
                      primary_phone: '123-456-7890',
                      other_phone: '333-444-5555'

  end

  describe 'index method' do
    before do
      # Not sure if there is a better way to do this, but just calling
      # `sign_in` a second time doesn't work as expected
      delete destroy_user_session_path
    end

    it 'should reject users without access' do
      sign_in @user

      get patients_path
      assert_redirected_to root_path

      get patients_path(format: :csv)
      assert_redirected_to root_path
    end

    it 'should not serve html' do
      sign_in @data_volunteer
      assert_raise ActionController::UnknownFormat do
        get patients_path
      end
    end

    it 'should get csv when user is admin' do
      sign_in @admin
      get patients_path(format: :csv)
      assert_response :success
    end

    it 'should get csv when user is data volunteer' do
      sign_in @data_volunteer
      get patients_path(format: :csv)
      assert_response :success
    end

#    it 'should not return archived patient for users' do
#      pass( "IOU") # TODO
#    end
#
#    it 'should return archived patient for data volunteers' do
#      pass( "IOU") # TODO
#    end
#
#    it 'should return archived patient for admin' do
#      pass( "IOU") # TODO
#    end

    it 'should use proper mimetype' do
      sign_in @data_volunteer
      get patients_path(format: :csv)
      assert_equal 'text/csv', response.content_type.split(';').first
    end

    it 'should consist of a header line and the patient record' do
      sign_in @data_volunteer
      get patients_path(format: :csv)
      lines = response.body.split("\n").reject(&:blank?)
      assert_equal 2, lines.count
      assert_match @patient.id.to_s, lines[1]
    end

    it 'should not contain personally-identifying information' do
      sign_in @data_volunteer
      get patients_path(format: :csv)
      refute_match @patient.name.to_s, response.body
      refute_match @patient.primary_phone.to_s, response.body
      refute_match @patient.other_phone.to_s, response.body
    end
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
        resolved_without_fund: true,
        fund_pledge: 100,
        clinic_id: @clinic.id
      }

      patch patient_path(@patient), params: { patient: @payload }, xhr: true
      @patient.reload
    end

    it 'should update pledge fields' do
      @payload[:pledge_sent] = true
      patch patient_path(@patient), params: { patient: @payload }, xhr: true
      @patient.reload
      assert_kind_of Time, @patient.pledge_sent_at
      assert_kind_of Object, @patient.pledge_sent_by
    end

    it 'should update last edited by' do
      assert_equal @user, @patient.last_edited_by
    end

    it 'should respond success on completion' do
      patch patient_path(@patient), params: { patient: @payload }, xhr: true
      assert_response :success
    end

    it 'should respond not acceptable error on failure' do
      @payload[:primary_phone] = nil
      patch patient_path(@patient), params: { patient: @payload }, xhr: true
      assert_response :not_acceptable
    end

    it 'should update patient fields' do
      assert_equal 'Susie Everyteen 2', @patient.name
    end

    it 'should redirect if record does not exist' do
      patch patient_path('notanactualid'), params: { patient: @payload }
      assert_redirected_to root_path
    end
  end

  describe 'pledge method' do
    it 'should respond success on completion' do
      get submit_pledge_path(@patient), xhr: true
      assert_response :success
    end
  end

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
      refute_nil @patient.reload.pledge_generated_by
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
