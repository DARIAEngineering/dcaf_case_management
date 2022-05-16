# Functions related to displaying notes
module NotesHelper
  def display_note_text_for(note)
    return nil if note.try(:full_text).blank?
    info = content_tag :p do
      content_tag(:strong) do
        t('note.most_recent', by: "#{note.created_by&.name}", at: "#{note.created_at.display_timestamp}")
      end
    end
    text = content_tag(:p) { note.full_text[0..400] }
    safe_join([info, text], '')
  end
end
