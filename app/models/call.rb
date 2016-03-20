class Call
	include Mongoid::Document
	include Mongoid::Timestamps
	include Mongoid::History

  allowed_statuses = ['Reached patient', 'Left voicemail', "Couldn't reach patient"]

	field :status, type: String
  # necessary because embedding things blows up belongs_to relationships
  field :creating_user_id, type: String
	embedded_in :pregnancy

	validates_presence_of :status
  validates :status,  presence: true, 
                      inclusion: { in: allowed_statuses }
end
