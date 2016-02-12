class Patient
	include Mongoid::Document

	field :first_name, type: String #strip
	field :last_name, type: String
	field :primary_phone, type: String #validate
	field :secondary_phone, type: String #validate

	has_many :cases

	def full_name
		"#{self.first_name} #{self.last_name}"
	end

end
