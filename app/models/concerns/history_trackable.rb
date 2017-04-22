# Methods pertaining to parsing history_tracks
module HistoryTrackable
  extend ActiveSupport::Concern

  included do
    include Mongoid::History::Trackable
    track_history on: self.fields.keys + [:updated_by_id],
                  version_field: :version,
                  track_create: true,
                  track_update: true,
                  track_destroy: true
  end

  def recent_history_tracks
    history_tracks.select { |ht| ht.updated_at > 6.days.ago }
  end
end
