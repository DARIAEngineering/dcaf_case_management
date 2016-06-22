class Note
  include Auditable
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

  # Relationships
  embedded_in :pregnancy

  # Fields
  field :full_text, type: String

  # Validations
  validates :created_by, :full_text, presence: true

end