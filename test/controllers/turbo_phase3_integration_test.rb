require 'test_helper'

# Integration tests for feature/turbo-migration-phase-3
# Builds on phase-2 and adds turbo_stream responses for:
#   - AccountantsController#edit
#   - CallsController#new, #create
#   - PatientsController#pledge, #update
#   - PracticalSupportsController#edit
#   - UsersController#search
class TurboPhase3IntegrationTest < ActionDispatch::IntegrationTest
  TURBO_STREAM_ACCEPT = { 'Accept' => 'text/vnd.turbo-stream.html' }.freeze

  before do
    @user = create :user
    sign_in @user
    @line = create :line
    choose_line @line
    @patient = create :patient, line: @line
  end

  # ---------------------------------------------------------------------------
  # AccountantsController#edit — turbo_stream modal content
  # ---------------------------------------------------------------------------
  describe 'accountants#edit turbo_stream responses' do
    before do
      @admin = create :user, role: :admin
      @clinic = create :clinic
      @pledge_patient = create :patient,
                               line: @line,
                               pledge_sent: true,
                               pledge_sent_at: 1.day.ago,
                               clinic: @clinic,
                               fund_pledge: 500
      # Sign in as admin (data_access required)
      delete destroy_user_session_path
      sign_in @admin
    end

    it 'should respond with turbo_stream format' do
      get edit_accountant_path(@pledge_patient),
          headers: TURBO_STREAM_ACCEPT
      assert_response :success
      assert_includes response.media_type, 'turbo-stream'
    end

    it 'should include turbo-stream tags in the response body' do
      get edit_accountant_path(@pledge_patient),
          headers: TURBO_STREAM_ACCEPT
      assert_match(/<turbo-stream/, response.body)
    end

    it 'should still respond to xhr (js) format for backward compatibility' do
      get edit_accountant_path(@pledge_patient), xhr: true
      assert_response :success
    end

    it 'should return unauthorized for non-admin users' do
      delete destroy_user_session_path
      sign_in @user  # regular CM user

      get edit_accountant_path(@pledge_patient),
          headers: TURBO_STREAM_ACCEPT
      assert_response :unauthorized
    end

    it 'should return unauthorized for data_volunteer users' do
      data_vol = create :user, role: :data_volunteer
      delete destroy_user_session_path
      sign_in data_vol

      get edit_accountant_path(@pledge_patient),
          headers: TURBO_STREAM_ACCEPT
      # data_volunteers have allowed_data_access? == true
      assert_response :success
    end
  end

  # ---------------------------------------------------------------------------
  # CallsController#new — turbo_stream response
  # ---------------------------------------------------------------------------
  describe 'calls#new turbo_stream responses' do
    it 'should respond with turbo_stream format' do
      get new_patient_call_path(@patient),
          headers: TURBO_STREAM_ACCEPT
      assert_response :success
      assert_includes response.media_type, 'turbo-stream'
    end

    it 'should include turbo-stream tags in the response body' do
      get new_patient_call_path(@patient),
          headers: TURBO_STREAM_ACCEPT
      assert_match(/<turbo-stream/, response.body)
    end

    it 'should still respond to xhr (js) format for backward compatibility' do
      get new_patient_call_path(@patient), xhr: true
      assert_response :success
    end
  end

  # ---------------------------------------------------------------------------
  # CallsController#create — turbo_stream response (non-redirect path)
  # ---------------------------------------------------------------------------
  describe 'calls#create turbo_stream responses' do
    it 'should redirect when patient is reached (regardless of format)' do
      call_attrs = attributes_for :call, status: :reached_patient
      post patient_calls_path(@patient),
           params: { call: call_attrs },
           headers: TURBO_STREAM_ACCEPT
      assert_redirected_to edit_patient_path(@patient)
    end

    it 'should respond with turbo_stream when patient is not reached' do
      [:left_voicemail, :couldnt_reach_patient].each do |status|
        call_attrs = attributes_for :call, status: status
        post patient_calls_path(@patient),
             params: { call: call_attrs },
             headers: TURBO_STREAM_ACCEPT
        assert_response :success
        assert_includes response.media_type, 'turbo-stream'
      end
    end

    it 'should include turbo-stream tags in the body when not redirecting' do
      call_attrs = attributes_for :call, status: :left_voicemail
      post patient_calls_path(@patient),
           params: { call: call_attrs },
           headers: TURBO_STREAM_ACCEPT
      assert_match(/<turbo-stream/, response.body)
    end

    it 'should actually create a new call' do
      call_attrs = attributes_for :call, status: :left_voicemail
      assert_difference 'Patient.find(@patient.id).calls.count', 1 do
        post patient_calls_path(@patient),
             params: { call: call_attrs },
             headers: TURBO_STREAM_ACCEPT
      end
    end

    it 'should return bad_request for invalid status' do
      [nil, 'not_a_real_status'].each do |bad_status|
        call_attrs = attributes_for :call, status: bad_status
        assert_no_difference 'Call.count' do
          post patient_calls_path(@patient),
               params: { call: call_attrs },
               headers: TURBO_STREAM_ACCEPT
        end
        assert_response :bad_request
      end
    end

    it 'should still respond to xhr (js) format for backward compatibility' do
      call_attrs = attributes_for :call, status: :left_voicemail
      post patient_calls_path(@patient),
           params: { call: call_attrs },
           xhr: true
      assert_response :success
    end
  end

  # ---------------------------------------------------------------------------
  # CallsController#destroy — turbo_stream (also phase-1, retested here)
  # ---------------------------------------------------------------------------
  describe 'calls#destroy turbo_stream responses' do
    before do
      with_versioning(@user) do
        @patient.calls.create attributes_for(:call)
      end
      @call = @patient.calls.first
    end

    it 'should respond with turbo_stream format' do
      delete patient_call_path(@patient, @call),
             params: { id: @call.id },
             headers: TURBO_STREAM_ACCEPT
      assert_response :success
      assert_includes response.media_type, 'turbo-stream'
    end

    it 'should include turbo-stream tags in the response body' do
      delete patient_call_path(@patient, @call),
             params: { id: @call.id },
             headers: TURBO_STREAM_ACCEPT
      assert_match(/<turbo-stream/, response.body)
    end

    it 'should return forbidden when user is not the creator' do
      other_user = create :user
      with_versioning(other_user) do
        @patient.calls.create attributes_for(:call)
      end
      other_call = @patient.calls.last

      delete patient_call_path(@patient, other_call),
             params: { id: other_call.id },
             headers: TURBO_STREAM_ACCEPT
      assert_response :forbidden
    end
  end

  # ---------------------------------------------------------------------------
  # PatientsController#pledge — turbo_stream response
  # ---------------------------------------------------------------------------
  describe 'patients#pledge turbo_stream responses' do
    it 'should respond with turbo_stream format' do
      get submit_pledge_path(@patient),
          headers: TURBO_STREAM_ACCEPT
      assert_response :success
      assert_includes response.media_type, 'turbo-stream'
    end

    it 'should include turbo-stream tags in the response body' do
      get submit_pledge_path(@patient),
          headers: TURBO_STREAM_ACCEPT
      assert_match(/<turbo-stream/, response.body)
    end

    it 'should still respond to xhr (js) format for backward compatibility' do
      get submit_pledge_path(@patient), xhr: true
      assert_response :success
    end
  end

  # ---------------------------------------------------------------------------
  # PatientsController#update — turbo_stream format added alongside js/json
  # ---------------------------------------------------------------------------
  describe 'patients#update turbo_stream responses' do
    before do
      @clinic = create :clinic
      @payload = {
        appointment_date: 5.days.from_now.to_date.strftime('%Y-%m-%d'),
        name: 'Updated Patient Name',
        fund_pledge: 200,
        clinic_id: @clinic.id
      }
    end

    it 'should respond with turbo_stream format on successful update' do
      patch patient_path(@patient),
            params: { patient: @payload },
            headers: TURBO_STREAM_ACCEPT
      assert_response :success
      assert_includes response.media_type, 'turbo-stream'
    end

    it 'should include saved flash message in turbo response body' do
      patch patient_path(@patient),
            params: { patient: @payload },
            headers: TURBO_STREAM_ACCEPT
      assert_includes response.body, 'saved'
    end

    it 'should actually update the patient record' do
      patch patient_path(@patient),
            params: { patient: @payload },
            headers: TURBO_STREAM_ACCEPT
      @patient.reload
      assert_equal 'Updated Patient Name', @patient.name
    end

    it 'should update last_edited_by' do
      patch patient_path(@patient),
            params: { patient: @payload },
            headers: TURBO_STREAM_ACCEPT
      @patient.reload
      assert_equal @user, @patient.last_edited_by
    end

    it 'should show error flash on validation failure via turbo_stream' do
      @payload[:primary_phone] = nil
      patch patient_path(@patient),
            params: { patient: @payload },
            headers: TURBO_STREAM_ACCEPT
      assert_includes response.body, 'alert'
    end

    it 'should redirect when patient record does not exist' do
      patch patient_path('notanactualid'),
            params: { patient: @payload }
      assert_redirected_to root_path
    end

    it 'should still respond to xhr (js) format for backward compatibility' do
      patch patient_path(@patient),
            params: { patient: @payload },
            xhr: true
      assert_response :success
      assert_includes response.body, 'saved'
    end

    it 'should still respond to json format' do
      patch patient_path(@patient),
            params: { patient: @payload },
            as: :json
      assert_response :success
      parsed = JSON.parse(response.body)
      assert_not_nil parsed['patient']
    end

    it 'should ignore pledge fulfillment attributes for non-admin' do
      @patient.update appointment_date: 5.days.from_now.to_date,
                      clinic: @clinic,
                      fund_pledge: 100
      @payload[:fulfillment_attributes] = @patient.fulfillment.attributes
      @payload[:fulfillment_attributes][:fund_payout] = 1_000
      patch patient_path(@patient),
            params: { patient: @payload },
            headers: TURBO_STREAM_ACCEPT
      assert_includes response.body, 'saved'
      @patient.fulfillment.reload
      assert_nil @patient.fulfillment.fund_payout
    end
  end

  # ---------------------------------------------------------------------------
  # PracticalSupportsController#edit — turbo_stream modal content
  # ---------------------------------------------------------------------------
  describe 'practical_supports#edit turbo_stream responses' do
    before do
      @patient.practical_supports.create support_type: 'Transit',
                                         confirmed: false,
                                         source: 'Transit'
      @support = @patient.practical_supports.first
    end

    it 'should respond with turbo_stream format' do
      get edit_patient_practical_support_path(@patient, @support),
          headers: TURBO_STREAM_ACCEPT
      assert_response :success
      assert_includes response.media_type, 'turbo-stream'
    end

    it 'should include turbo-stream tags in the response body' do
      get edit_patient_practical_support_path(@patient, @support),
          headers: TURBO_STREAM_ACCEPT
      assert_match(/<turbo-stream/, response.body)
    end

    it 'should still respond to xhr (js) format for backward compatibility' do
      get edit_patient_practical_support_path(@patient, @support), xhr: true
      assert_response :success
    end

    it 'should respond not_found for nonexistent support' do
      get edit_patient_practical_support_path(@patient, 'nonexistent'),
          headers: TURBO_STREAM_ACCEPT
      assert_response :not_found
    end
  end

  # ---------------------------------------------------------------------------
  # UsersController#search — turbo_stream response (admin only)
  # ---------------------------------------------------------------------------
  describe 'users#search turbo_stream responses' do
    before do
      @admin = create :user, role: :admin
      delete destroy_user_session_path
      sign_in @admin
    end

    it 'should respond with turbo_stream format' do
      post users_search_path,
           params: { search: @user.name },
           headers: TURBO_STREAM_ACCEPT
      assert_response :success
      assert_includes response.media_type, 'turbo-stream'
    end

    it 'should include turbo-stream tags in the response body' do
      post users_search_path,
           params: { search: @user.name },
           headers: TURBO_STREAM_ACCEPT
      assert_match(/<turbo-stream/, response.body)
    end

    it 'should return results for empty search (all users)' do
      post users_search_path,
           params: { search: '' },
           headers: TURBO_STREAM_ACCEPT
      assert_response :success
    end

    it 'should return unauthorized for non-admin users' do
      delete destroy_user_session_path
      sign_in @user  # regular CM user

      post users_search_path,
           params: { search: 'test' },
           headers: TURBO_STREAM_ACCEPT
      assert_response :unauthorized
    end

    it 'should still respond to xhr (js) format for backward compatibility' do
      post users_search_path,
           params: { search: @user.name },
           xhr: true
      assert_response :success
    end
  end
end
