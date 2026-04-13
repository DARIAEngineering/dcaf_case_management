require 'test_helper'

# Integration tests for feature/turbo-migration-phase-1
# Covers turbo_stream format responses added to:
#   - CallsController#destroy
#   - EventsController#index
#   - ExternalPledgesController#update, #destroy
class TurboPhase1IntegrationTest < ActionDispatch::IntegrationTest
  TURBO_STREAM_ACCEPT = { 'Accept' => 'text/vnd.turbo-stream.html' }.freeze

  before do
    @user = create :user
    sign_in @user
    @line = create :line
    choose_line @line
    @patient = create :patient, line: @line
  end

  # ---------------------------------------------------------------------------
  # CallsController#destroy — now responds to turbo_stream
  # ---------------------------------------------------------------------------
  describe 'calls#destroy turbo_stream responses' do
    before do
      with_versioning(@user) do
        @patient.calls.create attributes_for(:call)
      end
      @call = @patient.calls.first
    end

    it 'should respond with turbo_stream format when requested' do
      delete patient_call_path(@patient, @call),
             params: { id: @call.id },
             headers: TURBO_STREAM_ACCEPT
      assert_response :success
      assert_includes response.media_type, 'turbo-stream'
    end

    it 'should include a turbo-stream tag in the response body' do
      delete patient_call_path(@patient, @call),
             params: { id: @call.id },
             headers: TURBO_STREAM_ACCEPT
      assert_match(/<turbo-stream/, response.body)
    end

    it 'should actually destroy the call record' do
      assert_difference 'Patient.find(@patient.id).calls.count', -1 do
        delete patient_call_path(@patient, @call),
               params: { id: @call.id },
               headers: TURBO_STREAM_ACCEPT
      end
    end

    it 'should still respond to xhr (js) format for backward compatibility' do
      delete patient_call_path(@patient, @call),
             params: { id: @call.id },
             xhr: true
      assert_response :success
    end

    it 'should return forbidden when call was created by another user' do
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

    it 'should return forbidden for old calls' do
      with_versioning(@user) do
        @patient.calls.create attributes_for(:call, updated_at: 2.days.ago)
      end
      old_call = @patient.calls.last

      delete patient_call_path(@patient, old_call),
             params: { id: old_call.id },
             headers: TURBO_STREAM_ACCEPT
      assert_response :forbidden
    end

    it 'should return forbidden when call is not recent even with turbo format' do
      with_versioning(@user) do
        @patient.calls.create attributes_for(:call, updated_at: Time.zone.now - 1.day)
      end
      stale_call = @patient.calls.last

      delete patient_call_path(@patient, stale_call),
             params: { id: stale_call.id },
             headers: TURBO_STREAM_ACCEPT
      assert_response :forbidden
    end
  end

  # ---------------------------------------------------------------------------
  # EventsController#index — now responds to turbo_stream
  # ---------------------------------------------------------------------------
  describe 'events#index turbo_stream responses' do
    it 'should respond with turbo_stream format when requested' do
      get events_path, headers: TURBO_STREAM_ACCEPT
      assert_response :success
      assert_includes response.media_type, 'turbo-stream'
    end

    it 'should include a turbo-stream tag in the response body' do
      get events_path, headers: TURBO_STREAM_ACCEPT
      assert_match(/<turbo-stream/, response.body)
    end

    it 'should still respond with html format when not requesting turbo' do
      get events_path
      assert_response :success
    end

    it 'should still respond to xhr (js) format for backward compatibility' do
      get events_path, xhr: true
      assert_response :success
    end
  end

  # ---------------------------------------------------------------------------
  # ExternalPledgesController#update — changed to head :ok
  # ---------------------------------------------------------------------------
  describe 'external_pledges#update head :ok responses' do
    before do
      with_versioning(@user) do
        @patient.external_pledges.create source: 'Test Fund', amount: 100
      end
      @pledge = @patient.external_pledges.first
    end

    it 'should respond with head :ok on successful update' do
      patch patient_external_pledge_path(@patient, @pledge),
            params: { external_pledge: { source: 'Updated Fund' } },
            xhr: true
      assert_response :ok
    end

    it 'should actually update the pledge source' do
      patch patient_external_pledge_path(@patient, @pledge),
            params: { external_pledge: { source: 'Updated Fund' } },
            xhr: true
      @pledge.reload
      assert_equal 'Updated Fund', @pledge.source
    end

    it 'should respond bad_request on invalid update' do
      patch patient_external_pledge_path(@patient, @pledge),
            params: { external_pledge: { source: '' } },
            xhr: true
      assert_response :bad_request
    end

    it 'should respond not_found for nonexistent pledge' do
      patch patient_external_pledge_path(@patient, 'nonexistent'),
            params: { external_pledge: { source: 'Test' } },
            xhr: true
      assert_response :not_found
    end
  end

  # ---------------------------------------------------------------------------
  # ExternalPledgesController#destroy — changed to head :ok
  # ---------------------------------------------------------------------------
  describe 'external_pledges#destroy head :ok responses' do
    before do
      @patient.external_pledges.create source: 'Test Fund', amount: 50
      @pledge = @patient.external_pledges.first
    end

    it 'should respond with head :ok' do
      delete patient_external_pledge_path(@patient, @pledge), xhr: true
      assert_response :ok
    end

    it 'should set the pledge to inactive' do
      delete patient_external_pledge_path(@patient, @pledge), xhr: true
      @pledge.reload
      refute @pledge.active?
    end

    it 'should respond not_found for nonexistent pledge' do
      delete patient_external_pledge_path(@patient, 'nonexistent'), xhr: true
      assert_response :not_found
    end
  end
end
