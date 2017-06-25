# Functions related to displaying notes
module NotesHelper
  def plus_sign_glyphicon(note)
    return nil unless note && note.try(:full_text).length > 31
    note = tag(:span, class: 'glyphicon glyphicon-plus-sign',
                      title: 'Most recent note',
                      aria: { hidden: true },
                      data: { toggle: 'popover', placement: 'bottom',
                              content: note.full_text })
    sr = tag(:span, class: 'sr-only', text: 'Full note')
    safe_join([note, sr], '')
  end

  def display_note_text_for(note)
    return nil if note.try(:full_text).blank?
    info = content_tag :p do
      content_tag(:strong) do
        "Most recent note from #{note.created_by.name} " \
        "at #{note.created_at.display_timestamp}:"
      end
    end
    text = content_tag(:p) { note.full_text[0..400] }
    safe_join([info, text], '')
  end
end
