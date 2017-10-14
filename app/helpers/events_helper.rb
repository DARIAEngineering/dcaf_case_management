# Functions to display events for activity feed
module EventsHelper
  def display_event(event)
    safe_join [
      tag(:span,
          class: ['glyphicon', "glyphicon-#{event.glyphicon}", 'event-item']),
      log_entry(event)
    ], ' '
  end

  def append_new_event(event)

    @event = safe_join [
      tag(:span,
          class: ['glyphicon', "glyphicon-#{event.glyphicon}", 'event-item']),
      log_entry(event)
    ], ' '
    ActionCable.server.broadcast 'event_channel', event: @event
  end

  def log_entry(event)
    time = event.created_at.display_time.to_s
    str = "-- #{event.cm_name} #{event.event_text}"
    # pt_link = link_to(
    #   "#{event.patient_name}.",
    #   edit_patient_path(event.patient_id)
    # )
    # add_link = link_to(
    #   '(Add to call list)',
    #   add_patient_path(current_user, event.patient_id),
    #   method: :patch,
    #   remote: true
    # )
    pt_link = "#{event.patient_name}."
    add_link = ''

    safe_join [time, str, pt_link, add_link], ' '
  end
end
