# Keeps track of the history of objects (mostly patients).
# Primarily consumed by the change log partial of PatientsController#edit.
class AuditTrail
  include Mongoid::History::Tracker
  include Mongoid::Userstamp
  mongoid_userstamp user_model: 'User'

  IRRELEVANT_FIELDS = %w[user_ids updated_by_id pledge_sent_by_id last_edited_by_id].freeze

  # convenience methods for clean view display
  def date_of_change
    created_at.display_date
  end

  def has_changed_fields?
    modified.reject { |x| IRRELEVANT_FIELDS.include? x }.empty?
  end

  def shaped_changes
    orig = original.reject { |field| AuditTrail::IRRELEVANT_FIELDS.include? field }
    mod = modified.reject { |field| AuditTrail::IRRELEVANT_FIELDS.include? field }
    all_fields = orig.keys | mod.keys
    changeset = {}
    all_fields.each do |key|
      changeset[key.humanize] = { original: format_fieldchange(key, orig[key]),
                                  modified: format_fieldchange(key, modified[key]) }
    end
    changeset
  end

  def changed_from
    shaped_changes.values.map { |field| field[:original] }
  end

  def changed_to
    shaped_changes.values.map { |field| field[:modified] }
  end

  def format_fieldchange(key, value)
    return '(empty)' unless value.present?
    shaped_value = if %w[appointment_date initial_call_date pledge_generated_at].include? key
                     value.display_date
                   elsif value.is_a? Array # special circumstances, for example
                     value.reject(&:blank?).join(', ')
                   elsif key == 'clinic_id'
                     Clinic.where(id: value).first.&name
                   else
                     value
                   end
    return '(empty)' unless shaped_value.present?
    shaped_value 
  end

  def changed_by_user
    created_by ? created_by.name : 'System'
  end

  def marked_urgent?
    modified.include?('urgent_flag') && modified['urgent_flag'] == true
  end
end
