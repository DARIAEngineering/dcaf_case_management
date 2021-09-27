# Methods pertaining to urgent patients
module Urgency
  extend ActiveSupport::Concern

  def still_urgent?
    # Verify that a pregnancy has not been marked urgent in the past six days
    return false if resolved_without_fund
    recent = versions.where('created_at > ?', Config.urgent_reset.days.ago)
    return true if recent.any?(&:marked_urgent?)
    false
  end

  def confirm_still_urgent
    if urgent_flag
      update urgent_flag: false unless still_urgent?
    end
    true
  end

  class_methods do
    def urgent_patients(line)
      Patient.where(line: line, urgent_flag: true)
    end

    def trim_urgent_patients
      Patient.where(urgent_flag: true)
             .each(&:confirm_still_urgent)
    end
  end
end
