class Note < Active Record ::Base
  include Auditable
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

  embedded_in :pregnancy

  field :full_text, type: String

  validates :created_by, :full_text, presence: true
  
end
