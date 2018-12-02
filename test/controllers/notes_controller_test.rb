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
end
