# Methods pertaining to urgent patients
module Urgency
  extend ActiveSupport::Concern

  def still_urgent?
    # Verify that a pregnancy has not been marked urgent in the past six days
    return false if recent_history_tracks.count == 0
    return false if pledge_sent || resolved_without_fund
    recent_history_tracks.sort.reverse.each do |history|
      return true if history.marked_urgent?
    end
    false
  end

  class_methods do
    def urgent_patients(lines = LINES)
      Patient.in(_line: lines).where(urgent_flag: true)
    end

    def call_list(line, current_user)
      Patient.in(_line: line, user_ids: BSON::ObjectId(current_user.id)).where( :$and =>
      [ { :"calls.updated_at".ne => (8.hours.ago..Time.now) },
        { :"calls.created_by_id".ne => current_user.id } ]).order_by(created_at: :desc)

    end

    # def completed_calls(line, current_user)
    #   Patient.in(_line: line, user_ids: BSON::ObjectId(current_user.id)).where( :$and =>
    #   [ { :"calls.updated_at"  => (8.hours.ago..Time.now) },
    #     { :"calls.created_by_id" => current_user.id } ]).order_by(created_at: :asc)
    # end

    def trim_urgent_patients
      Patient.all do |patient|
        unless patient.still_urgent?
          patient.urgent_flag = false
          patient.save
        end
      end
    end
  end

  private

  def recent_history_tracks
    history_tracks.select { |ht| ht.updated_at > 6.days.ago }
  end
end
