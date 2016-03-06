class Patient
	include Mongoid::Document

	field :name, type: String #strip
	field :primary_phone, type: String #validate
	field :secondary_phone, type: String #validate

	has_many :pregnancies

  validates_presence_of :name, :primary_phone

  def self.search(name_or_phone_str) # TODO optimize
    name_matches = Patient.where name: name_or_phone_str
    primary_matches = Patient.where primary_phone: name_or_phone_str
    secondary_matches = Patient.where secondary_phone: name_or_phone_str
    results = []
    (name_matches | primary_matches | secondary_matches).each do |match|
      results << match
    end
    results
  end
end
