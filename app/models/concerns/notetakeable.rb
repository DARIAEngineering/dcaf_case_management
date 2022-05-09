# Methods relating to notes or parsing notes
module Notetakeable
  extend ActiveSupport::Concern

  def most_recent_note_display_text
    note_text = most_recent_note.try(:full_text).to_s
    display_note = note_text[0..20]
    display_note << '…' if note_text.length > 21
    display_note
  end

  def most_recent_note
    notes.order('created_at DESC').limit(1).first
  end
end
