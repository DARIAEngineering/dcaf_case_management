# Keeps track of the history of objects (mostly patients and pregnancies).
class AuditTrail
  include Mongoid::History::Tracker
  include Mongoid::Userstamp
  mongoid_userstamp user_model: 'User'

  # convenience methods for clean view display
  def date_of_change
    created_at.display_date
  end

  def changed_fields
    modified.keys.map(&:humanize)
  end

  def changed_from
    original.values
  end

  def changed_to
    modified.values
  end

  def changed_by_user
    nil # until I figure it out
    # User.find(created_by).name
  end

  def irrelevant_fields
    [:whatever]
  end

  def marked_urgent?
    modified.include?('urgent_flag') && modified['urgent_flag'] == true
  end
end
