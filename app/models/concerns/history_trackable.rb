# Methods pertaining to parsing history_tracks
module HistoryTrackable
  extend ActiveSupport::Concern

  def assemble_audit_trails
    history_tracks.sort_by(&:created_at).reverse
  end

  def recent_history_tracks
    history_tracks.select { |ht| ht.updated_at > 6.days.ago }
  end

  def created_by
    versions.first.whodunnit
  end

  def updated_by
    paper_trail.originator
  end
end
