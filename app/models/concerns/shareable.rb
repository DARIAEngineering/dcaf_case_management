# Methods pertaining to shared patients
module Shareable
  extend ActiveSupport::Concern

  def still_shared?
    # Verify that a pregnancy has not been shared in the past six days
    return false if resolved_without_fund
    recent = versions.where('created_at > ?', Config.shared_reset_days.days.ago)
    return true if recent.any?(&:marked_shared?)
    false
  end

  def confirm_still_shared
    if shared_flag
      update shared_flag: false unless still_shared?
    end
    true
  end

  class_methods do
    def shared_patients(line)
      Patient.where(line: line, shared_flag: true)
    end

    def trim_shared_patients
      Patient.where(shared_flag: true)
             .each(&:confirm_still_shared)
    end
  end
end
