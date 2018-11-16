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

  def changed_fields
    relevant_fields = modified.map do |key, _value|
      key unless IRRELEVANT_FIELDS.include? key
    end
    relevant_fields.compact.map(&:humanize)
  end

  # TODO: properly render null values like in special circumstances
  # Something like this should work:
  # "HAHA I WIN" if (fields.all?{|f| f.blank? || (f.flatten.all? &:blank? if f.respond_to?('each'))})

  def format_dates(hash)
    for key in ['appointment_date', 'initial_call_date', 'pledge_generated_at']
      if hash.has_key? key
        hash[key] = hash[key].display_date
      end
    end
    return hash
  end

  def format_special_circumstances(hash)
    hash.each do |key, value|
      if value.kind_of?(Array)
        hash[key].reject! { |item| item.blank? }
        if value.empty?
          hash[key] = 'not selected'
        end
      end
    end
    return hash
  end

  def parse_clinics(hash)
    if hash.key?('clinic_id')
      @clinic = Clinic.where(:id => hash["clinic_id"]).first
      hash["clinic_id"] = @clinic&.name # TODO not having a try here fails the update patient info test for some reason!
    end
    return hash
  end

  def changed_from
    format_special_circumstances(parse_clinics(format_dates(original))).map do |key, value|
      value unless IRRELEVANT_FIELDS.include? key
    end
  end

  def changed_to
    format_special_circumstances(parse_clinics(format_dates(modified))).map do |key, value|
      value unless IRRELEVANT_FIELDS.include? key
    end
  end

  def changed_by_user
    created_by ? created_by.name : 'System'
  end

  def marked_urgent?
    modified.include?('urgent_flag') && modified['urgent_flag'] == true
  end
end
