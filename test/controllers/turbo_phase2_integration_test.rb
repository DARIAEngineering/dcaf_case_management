require 'test_helper'

# Integration tests for feature/turbo-migration-phase-2
# Builds on phase-1 and adds turbo_stream responses for:
#   - ClinicfindersController#search
#   - DashboardsController#search
#   - ExternalPledgesController#create (turbo_stream added)
#   - NotesController#create
#   - PracticalSupportsController#create, #update, #destroy
#   - PracticalSupportsController error handling (flash_messages partial)
class TurboPhase2IntegrationTest < ActionDispatch::IntegrationTest
  TURBO_STREAM_ACCEPT = { 'Accept' => 'text/vnd.turbo-stream.html' }.freeze

  before do
    @user = create :user
    sign_in @user
    @line = create :line
    choose_line @line
    @patient = create :patient, line: @line
  end

  # ---------------------------------------------------------------------------
  # ClinicfindersController#search — turbo_stream response
  # ---------------------------------------------------------------------------
  describe 'clinicfinders#search turbo_stream responses' do
    before do
      @clinic = create :clinic, zip: '20011'
    end

    it 'should respond with turbo_stream format when requested with zip' do
      post clinicfinder_search_path,
           params: { zip: '20011' },
           headers: TURBO_STREAM_ACCEPT
      assert_response :success
      assert_includes response.media_type, 'turbo-stream'
    end

    it 'should include turbo-stream tags in the response body' do
      post clinicfinder_search_path,
           params: { zip: '20011' },
           headers: TURBO_STREAM_ACCEPT
      assert_match(/<turbo-stream/, response.body)
    end

    it 'should return bad_request when zip is blank' do
      post clinicfinder_search_path,
           params: { zip: '' },
           headers: TURBO_STREAM_ACCEPT
      assert_response :bad_request
    end

    it 'should return bad_request when zip param is missing' do
      post clinicfinder_search_path,
           headers: TURBO_STREAM_ACCEPT
      assert_response :bad_request
    end

    it 'should still respond to xhr (js) format for backward compatibility' do
      post clinicfinder_search_path,
           params: { zip: '20011' },
           xhr: true
      assert_response :success
    end

    it 'should accept gestation parameters' do
      post clinicfinder_search_path,
           params: { zip: '20011', gestation_weeks: '10', gestation_days: '3' },
           headers: TURBO_STREAM_ACCEPT
      assert_response :success
      assert_includes response.media_type, 'turbo-stream'
    end

    it 'should accept naf_only and medicaid_only filters' do
      post clinicfinder_search_path,
           params: { zip: '20011', naf_only: '1', medicaid_only: '1' },
           headers: TURBO_STREAM_ACCEPT
      assert_response :success
    end
  end

  # ---------------------------------------------------------------------------
  # DashboardsController#search — turbo_stream response
  # ---------------------------------------------------------------------------
  describe 'dashboards#search turbo_stream responses' do
    it 'should respond with turbo_stream format when searching' do
      post search_path,
           params: { search: @patient.name },
           headers: TURBO_STREAM_ACCEPT
      assert_response :success
      assert_includes response.media_type, 'turbo-stream'
    end

    it 'should include turbo-stream tags in the response body' do
      post search_path,
           params: { search: @patient.name },
           headers: TURBO_STREAM_ACCEPT
      assert_match(/<turbo-stream/, response.body)
    end

    it 'should return results for matching patient name' do
      post search_path,
           params: { search: @patient.name },
           headers: TURBO_STREAM_ACCEPT
      assert_response :success
    end

    it 'should return results for phone number search' do
      post search_path,
           params: { search: @patient.primary_phone },
           headers: TURBO_STREAM_ACCEPT
      assert_response :success
    end

    it 'should handle empty search gracefully' do
      post search_path,
           params: { search: '' },
           headers: TURBO_STREAM_ACCEPT
      assert_response :success
    end

    it 'should still respond to xhr (js) format for backward compatibility' do
      post search_path,
           params: { search: @patient.name },
           xhr: true
      assert_response :success
    end
  end

  # ---------------------------------------------------------------------------
  # ExternalPledgesController#create — turbo_stream added
  # ---------------------------------------------------------------------------
  describe 'external_pledges#create turbo_stream responses' do
    before do
      @pledge_attrs = attributes_for :external_pledge
    end

    it 'should respond with turbo_stream format on successful create' do
      post patient_external_pledges_path(@patient),
           params: { external_pledge: @pledge_attrs },
           headers: TURBO_STREAM_ACCEPT
      assert_response :success
      assert_includes response.media_type, 'turbo-stream'
    end

    it 'should include turbo-stream tags in the response body on success' do
      post patient_external_pledges_path(@patient),
           params: { external_pledge: @pledge_attrs },
           headers: TURBO_STREAM_ACCEPT
      assert_match(/<turbo-stream/, response.body)
    end

    it 'should actually create a new external pledge' do
      assert_difference 'Patient.find(@patient.id).external_pledges.count', 1 do
        post patient_external_pledges_path(@patient),
             params: { external_pledge: @pledge_attrs },
             headers: TURBO_STREAM_ACCEPT
      end
    end

    it 'should return bad_request when pledge is invalid' do
      post patient_external_pledges_path(@patient),
           params: { external_pledge: { source: '', amount: 100 } },
           headers: TURBO_STREAM_ACCEPT
      assert_response :bad_request
    end

    it 'should still respond to xhr (js) format for backward compatibility' do
      post patient_external_pledges_path(@patient),
           params: { external_pledge: @pledge_attrs },
           xhr: true
      assert_response :success
    end
  end

  # ---------------------------------------------------------------------------
  # NotesController#create — turbo_stream response
  # ---------------------------------------------------------------------------
  describe 'notes#create turbo_stream responses' do
    before do
      @note_attrs = attributes_for :note, full_text: 'This is a turbo note'
    end

    it 'should respond with turbo_stream format on successful create' do
      post patient_notes_path(@patient),
           params: { note: @note_attrs },
           headers: TURBO_STREAM_ACCEPT
      assert_response :success
      assert_includes response.media_type, 'turbo-stream'
    end

    it 'should include turbo-stream tags in the response body' do
      post patient_notes_path(@patient),
           params: { note: @note_attrs },
           headers: TURBO_STREAM_ACCEPT
      assert_match(/<turbo-stream/, response.body)
    end

    it 'should actually create a new note' do
      assert_difference 'Patient.find(@patient.id).notes.count', 1 do
        post patient_notes_path(@patient),
             params: { note: @note_attrs },
             headers: TURBO_STREAM_ACCEPT
      end
    end

    it 'should return bad_request when note text is blank' do
      post patient_notes_path(@patient),
           params: { note: { full_text: nil } },
           headers: TURBO_STREAM_ACCEPT
      assert_response :bad_request
    end

    it 'should still respond to xhr (js) format for backward compatibility' do
      post patient_notes_path(@patient),
           params: { note: @note_attrs },
           xhr: true
      assert_response :success
    end

    it 'should work for practical support notes via turbo_stream' do
      support = @patient.practical_supports.create(attributes_for(:practical_support))
      post practical_support_notes_path(support),
           params: { note: @note_attrs },
           headers: TURBO_STREAM_ACCEPT
      assert_response :success
      assert_includes response.media_type, 'turbo-stream'
    end
  end

  # ---------------------------------------------------------------------------
  # PracticalSupportsController#create — turbo_stream with flash
  # ---------------------------------------------------------------------------
  describe 'practical_supports#create turbo_stream responses' do
    before do
      @support_attrs = attributes_for :practical_support
    end

    it 'should respond with turbo_stream format on successful create' do
      post patient_practical_supports_path(@patient),
           params: { practical_support: @support_attrs },
           headers: TURBO_STREAM_ACCEPT
      assert_response :success
      assert_includes response.media_type, 'turbo-stream'
    end

    it 'should include turbo-stream tags in the response body' do
      post patient_practical_supports_path(@patient),
           params: { practical_support: @support_attrs },
           headers: TURBO_STREAM_ACCEPT
      assert_match(/<turbo-stream/, response.body)
    end

    it 'should actually create a new support record' do
      assert_difference 'Patient.find(@patient.id).practical_supports.count', 1 do
        post patient_practical_supports_path(@patient),
             params: { practical_support: @support_attrs },
             headers: TURBO_STREAM_ACCEPT
      end
    end

    it 'should set a flash notice on success' do
      post patient_practical_supports_path(@patient),
           params: { practical_support: @support_attrs },
           headers: TURBO_STREAM_ACCEPT
      assert_includes response.body, 'saved'
    end

    it 'should render flash_messages partial on validation failure via turbo_stream' do
      invalid_support = attributes_for :practical_support, source: 'x' * 151
      post patient_practical_supports_path(@patient),
           params: { practical_support: invalid_support },
           headers: TURBO_STREAM_ACCEPT
      assert_response :success
      assert_includes response.body, 'failed to save'
    end

    it 'should still respond to xhr (js) format for backward compatibility' do
      post patient_practical_supports_path(@patient),
           params: { practical_support: @support_attrs },
           xhr: true
      assert_response :success
    end
  end

  # ---------------------------------------------------------------------------
  # PracticalSupportsController#update — turbo_stream with flash
  # ---------------------------------------------------------------------------
  describe 'practical_supports#update turbo_stream responses' do
    before do
      @patient.practical_supports.create support_type: 'Transit',
                                         confirmed: false,
                                         source: 'Transit',
                                         amount: 10
      @support = @patient.practical_supports.first
    end

    it 'should respond with turbo_stream format on successful update' do
      patch patient_practical_support_path(@patient, @support),
            params: { practical_support: { support_type: 'Lodging' } },
            headers: TURBO_STREAM_ACCEPT
      assert_response :success
      assert_includes response.media_type, 'turbo-stream'
    end

    it 'should include turbo-stream tags in the response body' do
      patch patient_practical_support_path(@patient, @support),
            params: { practical_support: { support_type: 'Lodging' } },
            headers: TURBO_STREAM_ACCEPT
      assert_match(/<turbo-stream/, response.body)
    end

    it 'should actually update the support record' do
      patch patient_practical_support_path(@patient, @support),
            params: { practical_support: { support_type: 'Lodging' } },
            headers: TURBO_STREAM_ACCEPT
      @support.reload
      assert_equal 'Lodging', @support.support_type
    end

    it 'should include saved flash message on success' do
      patch patient_practical_support_path(@patient, @support),
            params: { practical_support: { support_type: 'Lodging' } },
            headers: TURBO_STREAM_ACCEPT
      assert_includes response.body, 'saved'
    end

    it 'should render flash_messages partial on validation failure via turbo_stream' do
      patch patient_practical_support_path(@patient, @support),
            params: { practical_support: { source: '' } },
            headers: TURBO_STREAM_ACCEPT
      assert_response :success
      assert_includes response.body, 'failed to save'
    end

    it 'should not allow negative amounts via turbo_stream' do
      patch patient_practical_support_path(@patient, @support),
            params: { practical_support: { amount: -5 } },
            headers: TURBO_STREAM_ACCEPT
      assert_includes response.body, 'failed to save'
    end

    it 'should respond not_found for nonexistent support' do
      patch patient_practical_support_path(@patient, 'nonexistent'),
            params: { practical_support: { support_type: 'Lodging' } },
            headers: TURBO_STREAM_ACCEPT
      assert_response :not_found
    end

    it 'should still respond to xhr (js) format for backward compatibility' do
      patch patient_practical_support_path(@patient, @support),
            params: { practical_support: { support_type: 'Lodging' } },
            xhr: true
      assert_response :success
    end
  end

  # ---------------------------------------------------------------------------
  # PracticalSupportsController#destroy — turbo_stream with flash
  # ---------------------------------------------------------------------------
  describe 'practical_supports#destroy turbo_stream responses' do
    before do
      @patient.practical_supports.create support_type: 'Transit',
                                         confirmed: false,
                                         source: 'Transit'
      @support = @patient.practical_supports.first
    end

    it 'should respond with turbo_stream format' do
      delete patient_practical_support_path(@patient, @support),
             headers: TURBO_STREAM_ACCEPT
      assert_response :success
      assert_includes response.media_type, 'turbo-stream'
    end

    it 'should include turbo-stream tags in the response body' do
      delete patient_practical_support_path(@patient, @support),
             headers: TURBO_STREAM_ACCEPT
      assert_match(/<turbo-stream/, response.body)
    end

    it 'should actually destroy the support record' do
      assert_difference 'Patient.find(@patient.id).practical_supports.count', -1 do
        delete patient_practical_support_path(@patient, @support),
               headers: TURBO_STREAM_ACCEPT
      end
    end

    it 'should include flash alert about removal' do
      delete patient_practical_support_path(@patient, @support),
             headers: TURBO_STREAM_ACCEPT
      assert_includes response.body, 'Removed practical support'
    end

    it 'should respond not_found for nonexistent support' do
      delete patient_practical_support_path(@patient, 'nonexistent'),
             headers: TURBO_STREAM_ACCEPT
      assert_response :not_found
    end

    it 'should still respond to xhr (js) format for backward compatibility' do
      delete patient_practical_support_path(@patient, @support),
             xhr: true
      assert_response :success
    end
  end
end
