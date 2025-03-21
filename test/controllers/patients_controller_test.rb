require 'test_helper'

class PatientsControllerTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    @admin = create :user, role: :admin
    @line = create :line
    @data_volunteer = create :user, role: :data_volunteer

    sign_in @user
    choose_line @line
    @clinic = create :clinic
    @patient = create :patient,
                      name: 'Susie Everyteen',
                      primary_phone: '123-456-7890',
                      other_phone: '333-444-5555',
                      line: @line,
                      city: '=injected_formula'
    @archived_patient = create :archived_patient,
                               line: @line,
                               initial_call_date: 400.days.ago
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
      get patients_path
      assert_equal response.status, 406
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

    it 'should use proper mimetype' do
      sign_in @data_volunteer
      get patients_path(format: :csv)
      assert_equal 'text/csv', response.content_type.split(';').first
    end

    it 'should consist of a header line, the patient record, and the archived patient record' do
      sign_in @data_volunteer
      get patients_path(format: :csv)
      lines = response.body.split("\n").reject(&:blank?)
      assert_equal 3, lines.count
      assert_match @patient.id.to_s, lines[1]
      assert_match @archived_patient.id.to_s, lines[2]
    end

    it 'should not contain personally-identifying information' do
      sign_in @data_volunteer
      get patients_path(format: :csv)
      assert_no_match @patient.name.to_s, response.body
      assert_no_match @patient.primary_phone.to_s, response.body
      assert_no_match @patient.other_phone.to_s, response.body
    end

    it 'should escape fields with attempted formula injection' do
      sign_in @data_volunteer
      get patients_path(format: :csv)
      lines = response.body.split("\n").reject(&:blank?)
      # A single quote at the beginning indicates it's escaped.
      assert_match "'=injected_formula", lines[1]
    end
  end

  describe 'create method' do
    before do
      @new_patient = attributes_for :patient, name: 'Test Patient', line_id: @line.id
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

    it 'should ignore pledge fulfillment attributes' do
      @new_patient[:fulfillment_attributes] = attributes_for :fulfillment, fulfilled: true, fund_payout: 1_000
      post patients_path, params: { patient: @new_patient }
      assert_nil Patient.find_by(name: 'Test Patient').fulfillment.fund_payout
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
    describe 'as HTML' do
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
        assert response.body.include? 'saved'
      end

      it 'should respond not acceptable error on failure' do
        @payload[:primary_phone] = nil
        patch patient_path(@patient), params: { patient: @payload }, xhr: true
        assert response.body.include? 'alert alert-danger'
      end

      it 'should update patient fields' do
        assert_equal 'Susie Everyteen 2', @patient.name
      end

      it 'should redirect if record does not exist' do
        patch patient_path('notanactualid'), params: { patient: @payload }
        assert_redirected_to root_path
      end

      it 'should ignore pledge fulfillment attributes' do
        assert_nil @patient.fulfillment.fund_payout
        @payload[:fulfillment_attributes] = @patient.fulfillment.attributes
        @payload[:fulfillment_attributes][:fund_payout] = 1_000
        patch patient_path(@patient), params: { patient: @payload }, xhr: true
        assert response.body.include? 'saved'
        @patient.fulfillment.reload
        assert_nil @patient.fulfillment.fund_payout
      end
    end

    describe 'as JSON' do
      before do
        @date = 5.days.from_now.to_date
        @payload = {
          appointment_date: @date.strftime('%Y-%m-%d'),
          name: 'Susie Everyteen 2',
          resolved_without_fund: true,
          fund_pledge: 100,
          clinic_id: @clinic.id
        }

        patch patient_path(@patient), params: { patient: @payload }, as: :json
        @patient.reload
      end

      it 'should update pledge fields' do
        @payload[:pledge_sent] = true
        patch patient_path(@patient), params: { patient: @payload }, as: :json
        @patient.reload
        assert_kind_of Time, @patient.pledge_sent_at
        assert_kind_of Object, @patient.pledge_sent_by
      end

      it 'should update last edited by' do
        assert_equal @user, @patient.last_edited_by
      end

      it 'should respond success on completion' do
        patch patient_path(@patient), params: { patient: @payload }, as: :json
        assert_not_nil JSON.parse(response.body)['patient']
      end

      it 'should respond not acceptable error on failure' do
        @payload[:primary_phone] = nil
        patch patient_path(@patient), params: { patient: @payload }, as: :json
        assert_not_nil JSON.parse(response.body)['flash']['alert']
      end

      it 'should update patient fields' do
        assert_equal 'Susie Everyteen 2', @patient.name
      end

      it 'should redirect if record does not exist' do
        patch patient_path('notanactualid'), params: { patient: @payload }
        assert_redirected_to root_path
      end

      it 'should ignore pledge fulfillment attributes' do
        assert_nil @patient.fulfillment.fund_payout
        @payload[:fulfillment_attributes] = @patient.fulfillment.attributes
        @payload[:fulfillment_attributes][:fund_payout] = 1_000
        patch patient_path(@patient), params: { patient: @payload }, as: :json
        assert response.body.include? 'saved'
        @patient.fulfillment.reload
        assert_nil @patient.fulfillment.fund_payout
      end
    end

    it 'should allow admins to change pledge fulfillment attributes' do
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

      delete destroy_user_session_path
      sign_in @admin

      assert_nil @patient.fulfillment.fund_payout
      bullet_enabled = Bullet.enable?
      Bullet.enable = false
      @payload[:fulfillment_attributes] = @patient.fulfillment.attributes
      @payload[:fulfillment_attributes][:fund_payout] = 1_000
      patch patient_path(@patient), params: { patient: @payload }, xhr: true
      assert response.body.include? 'saved'
      @patient.fulfillment.reload
      assert_equal 1_000, @patient.fulfillment.fund_payout
      Bullet.enable = bullet_enabled
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
      pdf_mock_result.expect :render, 'mow'
      assert_nil @patient.pledge_generated_at
      PledgeFormGenerator.stub(:new, pledge_generator_mock) do
        get generate_pledge_patient_path(@patient), params: { case_manager_name: 'somebody' }
      end

      assert_not_nil @patient.reload.pledge_generated_at
      assert_not_nil @patient.reload.pledge_generated_by
      assert_response :success
    end
  end

  describe 'fetch_pledge' do
    before do
      ActsAsTenant.current_tenant.build_pledge_config(remote_pledge_extras: {}).save
      @patient.update clinic: @clinic, appointment_date: Time.zone.now.strftime('%Y-%m-%d')
    end

    it 'should request a pdf from a service' do
      fake_result = Minitest::Mock.new
      fake_result.expect :ok?, true
      fake_result.expect :body, ''
      HTTParty.stub(:post, fake_result) do
        post fetch_pledge_patient_path(@patient), params: {}
      end
      assert_not_nil @patient.reload.pledge_generated_at
      assert_not_nil @patient.reload.pledge_generated_by
      assert_response :success
    end

    it 'should error cleanly' do
      fake_result = Minitest::Mock.new
      fake_result.expect :ok?, false
      HTTParty.stub(:post, fake_result) do
        post fetch_pledge_patient_path(@patient), params: {}
      end
      assert_nil @patient.reload.pledge_generated_at
      assert_nil @patient.reload.pledge_generated_by
      assert_response :redirect
    end
  end

  # confirm sending a 'post' with a payload results in a new patient
  describe 'data_entry_create method' do
    before do
      @test_patient = attributes_for :patient, name: 'Test Patient', line_id: create(:line).id
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
        assert_response :success
      end
    end

    it 'should create an associated fulfillment object' do
      post data_entry_create_path, params: { patient: @test_patient }
      assert_not_nil Patient.find_by(name: 'Test Patient').fulfillment
    end

    it 'should fail to save if initial call date is nil' do
      @test_patient[:initial_call_date] = nil
      @test_patient[:appointment_date] = Date.tomorrow
      assert_no_difference 'Patient.count' do
        post data_entry_create_path, params: { patient: @test_patient }
        assert_response :success
      end
    end
  end

  describe 'destroy' do
    describe 'authorization' do
      it 'should allow admins only' do
        [@user, @data_volunteer].each do |user|
          delete destroy_user_session_path
          sign_in @user

          assert_no_difference 'Patient.count' do
            delete patient_path(@patient)
          end
          assert_redirected_to root_url
        end
      end
    end

    describe 'behavior' do
      before do
        delete destroy_user_session_path
        sign_in @admin
      end

      it 'should destroy a patient' do
        assert_difference 'Patient.count', -1 do
          delete patient_path(@patient)
        end
        assert_not_nil flash[:notice]
      end

      it 'should prevent a patient from being destroyed under some circumstances' do
        @patient.update appointment_date: 2.days.from_now,
                        clinic: (create :clinic),
                        fund_pledge: 100,
                        pledge_sent: true

        assert_no_difference 'Patient.count' do
          delete patient_path(@patient)
        end
        assert_not_nil flash[:alert]
      end
    end
  end
end
