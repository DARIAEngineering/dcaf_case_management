# Functions to display events for activity feed
module EventsHelper
  def fontawesome_classes(event)
    kit = event.icon == 'thumbs-up' ? 'far' : 'fas'
    return "#{kit} fa-#{event.icon}"
  end

  def entry_text(event)
    time = event.created_at.display_time.to_s
    cm = event.cm_name
    event_text = event_string(event)
    pt_link = link_to event.patient_name,
                      edit_patient_path(event.patient_id)
    call_list_link = link_to "(#{t('events.add_to_call_list')})",
                             add_patient_path(event.patient_id),
                             method: :patch,
                             remote: true

    safe_join [time, '--', cm, event_text, pt_link, call_list_link], ' '
  end

  private

  def event_string(event)
    return t('events.pledged', pledge_amount: event.pledge_amount) if event.event_type == 'pledged'
    t("events.#{event.event_type}")
  end
end
