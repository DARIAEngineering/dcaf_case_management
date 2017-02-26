module NotesHelper
  def plus_sign_glyphicon(note)
    return nil unless note && note.try(:full_text).length > 31
    "<span class='glyphicon glyphicon-plus-sign' aria-hidden='true' " \
    "data-toggle='popover' data-placement='bottom' title='Most recent note' " \
    "data-content='#{h note.full_text}'>" \
    "</span><span class='sr-only'>Full note</span>".html_safe
  end

  def display_note_text_for(note)
    return nil unless note.try(:full_text).present?

    "<p><strong>Most recent note from #{h note.created_by.name} " \
    "at #{note.created_at.display_timestamp}:</strong></p>" \
    "<p>#{h note.full_text[0..400]}</p>".html_safe
  end
end
