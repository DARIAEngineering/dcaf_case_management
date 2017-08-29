module EventsHelper
  def display_event(event)
    safe_join [
      # TODO style this so it isn't the same as he regular call buttons
      tag(:span, class: ['glyphicon', "glyphicon-#{event.glyphicon}"]),
      log_entry(event)
    ], ' '
  end

  def log_entry(event)
    time = "#{event.created_at.display_date} #{event.created_at.display_time}"
    str = "-- #{event.cm_name} #{event.event_text}"
    link = link_to event.patient_name, edit_patient_path(event.patient_id)
    safe_join [time, str, link], ' '
  end
end
