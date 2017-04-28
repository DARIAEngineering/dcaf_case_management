# Methods pertaining to urgent patients
module Urgency
  extend ActiveSupport::Concern

  def still_urgent?
    # Verify that a pregnancy has not been marked urgent in the past six days
    return false if recent_history_tracks.count == 0
    return false if pledge_sent || resolved_without_dcaf
    recent_history_tracks.sort.reverse.each do |history|
      return true if history.marked_urgent?
    end
    false
  end

  class_methods do
    def urgent_patients(lines = LINES)
      Patient.in(_line: lines).where(urgent_flag: true)
    end

    def trim_urgent_patients
      Patient.all do |patient|
        unless patient.still_urgent?
          patient.urgent_flag = false
          patient.save
        end
      end
    end
  end

<<<<<<< HEAD
  private

  def recent_history_tracks
    history_tracks.select { |ht| ht.updated_at > 6.days.ago }
  end
=======
  # private

  # def recent_history_tracks
  #   history_tracks.select { |ht| ht.updated_at > 6.days.ago }
  # end
>>>>>>> b0887761f9a86e1181a62d014493cded481091a5
end
