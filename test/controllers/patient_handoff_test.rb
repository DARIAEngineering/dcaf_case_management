require 'test_helper'

class PatientHandoffTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    @target_user = create :user
    @line = create :line
    @patient = create :patient
    sign_in @user
    choose_line @line
    # Put patient on current user's call list (required for handoff auth)
    @user.add_patient(@patient)
  end

  describe 'handoff action' do
    it 'should hand off patient to target user' do
      post handoff_patient_path(@patient), params: {
        target_user_id: @target_user.id,
        handoff_note: 'Transferring for follow-up'
      }
      assert_redirected_to edit_patient_path(@patient)

      @patient.reload
      assert_equal @target_user.id, @patient.handed_off_to_id
      assert_equal @user.id, @patient.handed_off_from_id
      assert_equal 'Transferring for follow-up', @patient.handoff_note
      assert_not_nil @patient.handed_off_at
    end

    it 'should create a note documenting the handoff' do
      assert_difference '@patient.notes.count', 1 do
        post handoff_patient_path(@patient), params: {
          target_user_id: @target_user.id
        }
      end

      note = @patient.notes.last
      assert_match @user.name, note.full_text
      assert_match @target_user.name, note.full_text
    end

    it 'should work without a handoff note' do
      post handoff_patient_path(@patient), params: {
        target_user_id: @target_user.id
      }
      assert_redirected_to edit_patient_path(@patient)

      @patient.reload
      assert_nil @patient.handoff_note
    end

    it 'should reject invalid target_user_id' do
      assert_raises ActiveRecord::RecordNotFound do
        post handoff_patient_path(@patient), params: {
          target_user_id: 999999
        }
      end
    end

    it 'should set flash notice on success' do
      post handoff_patient_path(@patient), params: {
        target_user_id: @target_user.id
      }
      assert_match @patient.name, flash[:notice]
      assert_match @target_user.name, flash[:notice]
    end

    it 'should transfer patient from source to target call list' do
      assert CallListEntry.where(patient: @patient, user: @user).exists?,
             'precondition: patient should be on source user call list'

      post handoff_patient_path(@patient), params: {
        target_user_id: @target_user.id
      }

      refute CallListEntry.where(patient: @patient, user: @user).exists?,
             'patient should be removed from source user call list'
      assert CallListEntry.where(patient: @patient, user: @target_user).exists?,
             'patient should be added to target user call list'
    end

    it 'should record a recent handed_off_at timestamp' do
      freeze_time do
        post handoff_patient_path(@patient), params: {
          target_user_id: @target_user.id
        }
        @patient.reload
        assert_equal Time.current, @patient.handed_off_at
      end
    end

    it 'should include handoff note in the created note text' do
      post handoff_patient_path(@patient), params: {
        target_user_id: @target_user.id,
        handoff_note: 'Needs Spanish speaker'
      }

      note = @patient.notes.last
      assert_match 'Needs Spanish speaker', note.full_text
    end
  end

  describe 'handoff authorization' do
    it 'should require authentication' do
      delete user_session_path # sign out
      post handoff_patient_path(@patient), params: {
        target_user_id: @target_user.id
      }
      assert_response :redirect
      @patient.reload
      assert_nil @patient.handed_off_to_id
    end

    it 'should allow admin even without patient on call list' do
      @user.update!(role: :admin)
      @user.remove_patient(@patient)

      post handoff_patient_path(@patient), params: {
        target_user_id: @target_user.id
      }
      assert_redirected_to edit_patient_path(@patient)
      @patient.reload
      assert_equal @target_user.id, @patient.handed_off_to_id
    end

    it 'should reject CM who does not have patient on call list' do
      @user.remove_patient(@patient)

      post handoff_patient_path(@patient), params: {
        target_user_id: @target_user.id
      }
      assert_redirected_to edit_patient_path(@patient)
      assert_equal 'Not authorized.', flash[:alert]
      @patient.reload
      assert_nil @patient.handed_off_to_id
    end

    it 'should reject data volunteer' do
      @user.update!(role: :data_volunteer)

      post handoff_patient_path(@patient), params: {
        target_user_id: @target_user.id
      }
      assert_redirected_to edit_patient_path(@patient)
      assert_equal 'Not authorized.', flash[:alert]
    end
  end
end