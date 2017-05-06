require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @patient = create :patient
    @note = create :note, patient: @patient, created_by: @user
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

    it 'requires a creator' do
      @note.created_by = nil
      refute @note.valid?
    end
  end

  describe 'relationships' do
    it 'should have an associated patient' do
      assert @note.respond_to? :patient
      assert @note.patient
    end
  end

  describe 'mongoid attachments' do
    it 'should have timestamps from Mongoid::Timestamps' do
      [:created_at, :updated_at].each do |field|
        assert @note.respond_to? field
        assert @note[field]
      end
    end

    it 'should respond to history methods' do
      assert @note.respond_to? :history_tracks
      assert @note.history_tracks.count > 0
    end

    it 'should have accessible userstamp methods' do
      assert @note.respond_to? :created_by
      assert @note.created_by
    end
  end
end
