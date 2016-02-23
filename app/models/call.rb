class Call
	include Mongoid::Document
	include Mongoid::Timestamps
	include Mongoid::History

	field :status, type: String
	embedded_in :pregnancy

	validates_presence_of :status

end
