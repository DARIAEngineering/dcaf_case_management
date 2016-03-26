class AuditTrail
  include Mongoid::History::Tracker

  # convenience methods for clean view display
  def date_of_edit
    created_at.getlocal.strftime("%Y-%m-%d")
  end

  def tracked_changes_fields
    modified.keys.map { |k| k.humanize }.join('<br>').html_safe
  end

  def tracked_changes_from
    original.values.join('<br>').html_safe
  end

  def tracked_changes_to
    modified.values.join('<br>').html_safe
  end
end
