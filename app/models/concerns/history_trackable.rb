# Methods pertaining to parsing history_tracks
module HistoryTrackable
  extend ActiveSupport::Concern

  def assemble_audit_trails
    versions.order(created_at: :desc)
  end

  def recent_history_tracks
    versions.select { |v| v.created_at > 6.days.ago }
  end
end
