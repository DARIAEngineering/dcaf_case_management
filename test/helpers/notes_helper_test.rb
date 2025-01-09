require 'test_helper'

class NotesHelperTest < ActionView::TestCase
  include ERB::Util

  describe 'display_note_text_for method' do
    before do
      with_versioning(create(:user)) do
        patient = create :patient
        @note = patient.notes.create attributes_for(:note)
      end
    end

    it 'should return nil if note does not have text' do
      @note.full_text = nil
      assert_nil display_note_text_for @note
    end

    it 'should return note name, timestamp, and full text if it has text' do
      displayed_note_text = display_note_text_for @note

      assert_match @note.created_at.display_timestamp, displayed_note_text
      assert_match @note.full_text, displayed_note_text
      assert_match @note.created_by.name, displayed_note_text
    end
  end
end
