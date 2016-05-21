 class Call
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp
  include Auditable

  embedded_in :pregnancy

  allowed_statuses = ['Reached patient', 'Left voicemail', "Couldn't reach patient"]

  field :status, type: String

  validates :status,  presence: true,
                      inclusion: { in: allowed_statuses }
  validates :created_by, presence: true

 
end
