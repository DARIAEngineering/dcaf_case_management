class Note
	include Mongoid::Document
	include Mongoid::TimeStamps
	#include Mongoid::History

	field :notes, type: String
	embedded_in :case
	
end