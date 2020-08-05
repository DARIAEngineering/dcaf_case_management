# Methods pertaining to urgent patients
module Urgency
  extend ActiveSupport::Concern

  def still_urgent?
    # Verify that a pregnancy has not been marked urgent in the past six days
    return false if recent_history_tracks.count.zero?
    return false if pledge_sent || resolved_without_fund
    recent_history_tracks.order(created_at: :desc).each do |version|
      # uh oh.
      return true if version.marked_urgent?
    end
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

  private

  def recent_history_tracks
    versions.where(created_at: 6.days.ago..)
  end
end
