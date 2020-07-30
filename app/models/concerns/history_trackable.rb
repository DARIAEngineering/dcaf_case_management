# Methods pertaining to parsing history_tracks
module HistoryTrackable
  extend ActiveSupport::Concern

  def assemble_audit_trails
    versions.order_by(created_at: :desc)
  end

  def recent_history_tracks
    versions.where updated_at: 6.days.ago..
  end

  def created_by
    versions.order_by(created_at: :asc).first.whodunnit
  end

  def created_by_id
    created_by.id
  end
end
