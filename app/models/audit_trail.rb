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
    relevant_fields = modified.map do |key, value|
      key unless irrelevant_fields.include? key
    end

    relevant_fields.compact.map(&:humanize)
  end

  def changed_from
    relevant_fields = original.map do |key, value|
      value unless irrelevant_fields.include? key
    end

    relevant_fields.compact
  end

  def changed_to
    relevant_fields = modified.map do |key, value|
      value unless irrelevant_fields.include? key
    end

    relevant_fields.compact
  end

  def changed_by_user
    created_by ? created_by.name : 'System'
  end

  def irrelevant_fields
    %w(user_ids updated_by)
  end

  def marked_urgent?
    modified.include?('urgent_flag') && modified['urgent_flag'] == true
  end
end
