require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @pregnancy = create :pregnancy
    @note = create :note, pregnancy: @pregnancy, created_by: @user
  end

  describe 'validation' do
    it 'is valid' do
      assert @note.valid?
    end

    it 'requires full text' do
      @note.full_text = ''
      refute @note.valid?
      @note.full_text = nil
      refute @note.valid?
    end

    it 'requires a real user' do
      @note.created_by_id = nil
      refute @note.valid?
      @note.created_by_id = 'not a user'
      refute @note.valid?
    end
  end

  describe 'relationships' do
    it 'should have a pregnancy' do
      assert @note.respond_to? :pregnancy
      assert @note.pregnancy
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
