module EventsHelper
  def display_event(event)
    # glyphicon = content_tag :span, class: "glyphicon glyphicon-#{event.glyphicon}"
    # safe_join [glyphicon, event.to_log_entry], ' '
    event.to_log_entry
  end
end
