# Methods pertaining to parsing history_tracks
module HistoryTrackable
  extend ActiveSupport::Concern

  included do
    has_paper_trail versions: { class_name: 'HistoryTracker',
                                scope: -> { order(id: :desc) } }
  end

  def assemble_audit_trails
    versions # mark for deprecation
  end

  def created_by
    versions.first&.actor
  end

  def created_by_id
    created_by&.id
  end
end
