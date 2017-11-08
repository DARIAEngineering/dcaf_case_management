# Methods pertaining to urgent patients
module Urgency
  extend ActiveSupport::Concern

  def still_urgent?
    # Verify that a pregnancy has not been marked urgent in the past six days
    return false if recent_history_tracks.count.zero?
    return false if pledge_sent || resolved_without_fund
    recent_history_tracks.sort.reverse.each do |history|
      return true if history.marked_urgent?
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
    def urgent_patients(lines = LINES)
      Patient.in(line: lines).where(urgent_flag: true)
    end

    def trim_urgent_patients
      Patient.where(urgent_flag: true)
             .each(&:confirm_still_urgent)
    end
  end

  private

  def recent_history_tracks
    history_tracks.select { |ht| ht.updated_at > 6.days.ago }
  end
end
