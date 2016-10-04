require 'test_helper'

class NotesHelperTest < ActionView::TestCase
  include ERB::Util

  describe 'plus sign glyphicon method' do
    it 'should return nil if the text is under 40 char' do
      under_40_char = create :note, full_text: 'yolo goat'
      assert_nil plus_sign_glyphicon under_40_char
    end

    it 'should return a glyphicon if the text is over 40 char' do
      over_40_char = create :note, full_text: 'this is 40 character or ' \
                                              'so cats are great so fluffy'
      refute_nil plus_sign_glyphicon over_40_char
    end
  end

  describe 'display_note_text_for method' do
    it 'should return nil if note does not have text' do
      note = build :note, full_text: nil
      assert_nil display_note_text_for note
    end

    it 'should return note name, timestamp, and full text if it has text' do
      note = create :note
      displayed_note_text = display_note_text_for note

      assert_match note.created_at.display_timestamp, displayed_note_text
      assert_match note.full_text, displayed_note_text
      assert_match note.created_by.name, displayed_note_text
    end
  end
end
