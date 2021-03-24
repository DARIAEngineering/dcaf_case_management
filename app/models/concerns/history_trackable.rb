# Methods pertaining to parsing history_tracks
module HistoryTrackable
  extend ActiveSupport::Concern

  def assemble_audit_trails
    # This is only used in one place and should be killable after we port Patient over
    if try(:superclass) == ApplicationRecord
      versions
    else
      history_tracks.includes(:created_by).sort_by(&:created_at).reverse
    end
  end

  def recent_history_tracks
    if try(:superclass) == ApplicationRecord
      versions.where(updated_at: 6.days.ago..)
    else
      # Mongo compatibility
      history_tracks.select { |ht| ht.updated_at > 6.days.ago }
    end
  end
end
