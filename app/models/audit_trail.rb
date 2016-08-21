class AuditTrail
  include Mongoid::History::Tracker

  # convenience methods for clean view display
  def tracked_changes_fields
    modified.keys.map(&:humanize).join('<br>').html_safe
  end

  def tracked_changes_from
    original.values.join('<br>').html_safe
  end

  def tracked_changes_to
    modified.values.join('<br>').html_safe
  end

  def marked_urgent?
    modified.include?('urgent_flag') && modified['urgent_flag'] == true
  end
end
