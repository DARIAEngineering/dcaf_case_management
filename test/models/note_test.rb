require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  before do
    @user = create :user
    with_versioning(@user) do
      @patient = create :patient
      @patient.notes.create attributes_for(:note)
      @note = @patient.notes.first
    end
  end

  describe 'validation' do
    it 'should build' do
      assert @note.valid?
    end

    it 'requires full text' do
      @note.full_text = ''
      refute @note.valid?
      @note.full_text = nil
      refute @note.valid?
    end
  end

  describe 'relationships' do
    it 'should have an associated patient' do
      assert @note.respond_to? :can_note
      assert_equal @note.can_note, @patient
    end
  end

  describe 'concerns' do
    it 'should respond to history methods' do
      assert @note.respond_to? :versions
      assert @note.respond_to? :created_by
      assert @note.respond_to? :created_by_id
    end
  end
end
