# Keeps track of the history of objects (mostly patients).
# Primarily consumed by the change log partial of PatientsController#edit.
class AuditTrail
  include Mongoid::History::Tracker
  include Mongoid::Userstamp
  mongoid_userstamp user_model: 'User'

  IRRELEVANT_FIELDS = %w[user_ids updated_by].freeze

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

  def formatDates(hash)
    for key in ['appointment_date', 'initial_call_date', 'pledge_generated_at']
      if hash.has_key? key
        hash[key] = Date.strptime(hash[key].to_s, "%Y-%m-%d %H:%M:%S %Z").strftime('%m-%d-%Y')
      end
    end
    return hash
  end

  # TODO make columns more consistent in height
  def formatEmptyArrays(hash)
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

  def parseClinics(hash)
    if hash.key?('clinic_id')
      @clinic = Clinic.where(:id => hash["clinic_id"]).first
      hash["clinic_id"] = @clinic.name
    end
    return hash
  end

  def changed_from
    formatEmptyArrays(parseClinics(formatDates(original))).map do |key, value|
      value unless IRRELEVANT_FIELDS.include? key
    end
  end

  def changed_to
    formatEmptyArrays(parseClinics(formatDates(modified))).map do |key, value|
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
