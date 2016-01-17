class Patient
	include Mongoid::Document

	field :name, type: String
	field :primary_phone, type: String
	field :secondary_phone, type: String

	has_many :cases

end