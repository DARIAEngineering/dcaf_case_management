class Patient
	include Mongoid::Document

	field :name, type: String #strip
	field :primary_phone, type: String #validate
	field :secondary_phone, type: String #validate

	has_many :pregnancy_cases

  validates_presence_of :name, :primary_phone
end
