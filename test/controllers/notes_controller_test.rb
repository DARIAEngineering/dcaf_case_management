require 'test_helper'

class NotesControllerTest < ActionController::TestCase
  before do
    @user = create :user
    sign_in @user
    @patient = create :patient
  end

  describe 'create method' do
    before do
      @note = attributes_for :note, full_text: 'This is a note'
      post :create, patient_id: @patient, note: @note, format: :js
    end

    it 'should create and save a new note' do
      assert_difference '@patient.notes.count', 1 do
        post :create, patient_id: @patient, note: @note, format: :js
      end
    end

    it 'should respond success if the note submits' do
      assert_response :success
    end

    it 'should render create.js.erb if it successfully saves' do
      assert_template 'notes/create'
    end

    it 'should log the creating user' do
      assert_equal @patient.notes.last.created_by, @user
    end

    it 'should alert failure if there is not text or an associated patient' do
      @note[:full_text] = nil
      assert_no_difference '@patient.notes.count' do
        post :create, patient_id: @patient, note: @note, format: :js
      end
      assert_response :bad_request
    end
  end

  describe 'update method' do
    before do
      @note = create :note, patient: @patient, full_text: 'Original text'
      @note_edits = attributes_for :note, full_text: 'This is edited text'
      patch :update, patient_id: @patient,
                     id: @note,
                     note: @note_edits,
                     format: :js
      @note.reload
    end

    it 'should render the correct template' do
      assert_template 'notes/update'
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
        assert_no_difference '@patient.notes.find(@note).history_tracks.count' do
          @note_edits[:full_text] = bad_text
          patch :update, patient_id: @patient, id: @note,
                         note: @note_edits, format: :js
          assert_response :bad_request
          @note.reload
          assert_equal @note.full_text, 'This is edited text'
        end
      end
    end
  end
end
