# Methods pertaining to parsing history_tracks
module HistoryTrackable
  extend ActiveSupport::Concern

  def assemble_audit_trails
    versions.order(created_at: :desc)
  end

  def created_by
    versions.order(created_at: :asc).first&.actor
  end

  def created_by_id
    created_by&.id
  end
end
