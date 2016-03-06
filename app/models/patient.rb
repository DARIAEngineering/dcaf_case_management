class Patient
	include Mongoid::Document

	field :name, type: String #strip
	field :primary_phone, type: String #validate
	field :secondary_phone, type: String #validate

	has_many :pregnancies

  validates_presence_of :name, :primary_phone

  def search(name_or_phone_str)
    name_match = Patient.where(name: params[:search])
    primary_match = Patient.where(primary_phone: params[:search])
    secondary_match = Patient.where(secondary_phone: params[:search])
    name_match | primary_match | secondary_match
  end
end
