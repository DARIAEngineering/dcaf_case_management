class Clinic
	include Mongoid::Document

	field :name, type: String
	field :street_address_1, type: String
	field :street_address_2, type: String
	field :city, type: String
	field :state, type: String #ennnnnnummmmerrrrattttttioonnn???????
	field :zip, type: String

	belongs_to :pregnancy_case

end
