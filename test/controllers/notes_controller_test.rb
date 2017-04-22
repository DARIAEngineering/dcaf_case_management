require 'test_helper'

class NotesControllerTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    sign_in @user
    @patient = create :patient
  end

  describe 'create method' do
    before do
      @note = attributes_for :note, full_text: 'This is a note'
      post patient_notes_path(@patient), params: { note: @note }, xhr: true
    end

    it 'should create and save a new note' do
      assert_difference 'Patient.find(@patient).notes.count', 1 do
        post patient_notes_path(@patient), params: { note: @note }, xhr: true
      end
    end

    it 'should respond success if the note submits' do
      assert_response :success
    end

    it 'should log the creating user' do
      assert_equal Patient.find(@patient).notes.first.created_by, @user
    end

    it 'should alert failure if there is not text or an associated patient' do
      @note[:full_text] = nil
      assert_no_difference 'Patient.find(@patient).notes.count' do
        post patient_notes_path(@patient), params: { note: @note }, xhr: true
      end
      assert_response :bad_request
    end
  end

  # Note: Unimplemented from frontend, but available just in case
  describe 'update method' do
    before do
      @note = create :note, patient: @patient, full_text: 'Original text'
      @note_edits = attributes_for :note, full_text: 'This is edited text'
      patch patient_note_path(@patient, @note), params: { note: @note_edits }, xhr: true
      @note.reload
    end

    it 'should respond with success' do
      assert_response :success
    end

    it 'should update the full_text field' do
      assert_equal @note.full_text, 'This is edited text'
    end

    it 'should have an audit trail' do
      assert_equal @note.history_tracks.count, 2
      @changes = @note.history_tracks.last
      assert_equal @changes.modified[:updated_by_id], @user.id
      assert_equal @changes.modified[:full_text], 'This is edited text'
    end

    it 'should refuse to save note content to blank' do
      [nil, ''].each do |bad_text|
        assert_no_difference '@patient.notes
                                      .find(@note)
                                      .history_tracks.count' do
          @note_edits[:full_text] = bad_text
          patch patient_note_path(@patient, @note), params: { note: @note_edits }, xhr: true
          assert_response :bad_request
          @note.reload
          assert_equal @note.full_text, 'This is edited text'
        end
      end
    end
  end
end
