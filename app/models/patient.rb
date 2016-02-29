class Patient
	include Mongoid::Document

	has_many :cases

	validates_presence_of :name, :primary_phone

	field :name, type: String #strip
	field :primary_phone, type: String #validate
	field :secondary_phone, type: String #validate

end
