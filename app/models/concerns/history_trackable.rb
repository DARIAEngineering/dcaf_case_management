# Methods pertaining to parsing history_tracks
module HistoryTrackable
  extend ActiveSupport::Concern

  def assemble_audit_trails
    history_tracks.includes(:created_by).sort_by(&:created_at).reverse
  end

  def recent_history_tracks
    versions.select { |v| v.created_at > 6.days.ago }
  end
end
