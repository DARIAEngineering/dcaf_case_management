# Keeps track of the history of objects (mostly patients and pregnancies)
class AuditTrail
  include Mongoid::History::Tracker

  # convenience methods for clean view display
  def tracked_changes_fields
    modified.keys.map(&:humanize)
  end

  def tracked_changes_from
    original.values
  end

  def tracked_changes_to
    modified.values
  end

  def marked_urgent?
    modified.include?('urgent_flag') && modified['urgent_flag'] == true
  end
end
