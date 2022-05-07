# Methods pertaining to flagged patients
module Flaggable
  extend ActiveSupport::Concern

  def still_flagged?
    # Verify that a pregnancy has not been flagged in the past six days
    return false if resolved_without_fund
    recent = versions.where('created_at > ?', Config.flagged_reset.days.ago)
    return true if recent.any?(&:marked_flagged?)
    false
  end

  def confirm_still_flagged
    if flagged
      update flagged: false unless still_flagged?
    end
    true
  end

  class_methods do
    def flagged_patients(line)
      Patient.where(line: line, flagged: true)
    end

    def trim_flagged_patients
      Patient.where(flagged: true)
             .each(&:confirm_still_flagged)
    end
  end
end
