require 'test_helper'

class NotesControllerTest < ActionDispatch::IntegrationTest
  before do
    @user = create :user
    sign_in @user
    @patient = create :patient
  end

  describe 'create method' do
    before do
      with_versioning(@user) do
        @note = attributes_for :note, full_text: 'This is a note'
        post patient_notes_path(@patient), params: { note: @note }, xhr: true
      end
    end

    it 'should create and save a new note' do
      assert_difference 'Patient.find(@patient.id).notes.count', 1 do
        post patient_notes_path(@patient), params: { note: @note }, xhr: true
      end
    end

    it 'should respond success if the note submits' do
      assert_response :success
    end

    it 'should log the creating user' do
      assert_equal Patient.find(@patient.id).notes.first.created_by, @user
    end

    it 'should alert failure if there is not text or an associated patient' do
      @note[:full_text] = nil
      assert_no_difference 'Patient.find(@patient.id).notes.count' do
        post patient_notes_path(@patient), params: { note: @note }, xhr: true
      end
      assert_response :bad_request
    end

    it 'should allow practical support' do
      with_versioning(@user) do
        support = @patient.practical_supports.create(attributes_for :practical_support)
        note = attributes_for :note, full_text: 'This is a note'
        post practical_support_notes_path(support), params: { note: note }, xhr: true
      end
    end
  end
end
