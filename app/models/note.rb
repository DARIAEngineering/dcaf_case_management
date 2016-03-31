class Note
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

  embedded_in :pregnancy

  field :notes, type: String

  validates :created_by, presence: true

  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true

  mongoid_userstamp user_model: 'User'


end
