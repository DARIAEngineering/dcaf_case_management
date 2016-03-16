class Patient
	include Mongoid::Document
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

	has_many :pregnancies

	validates_presence_of :name, :primary_phone

	field :name, type: String #strip
	field :primary_phone, type: String #validate
  field :secondary_person, type: String
	field :secondary_phone, type: String

  track_history   :on => [:name, :primary_phone, :secondary_person, :secondary_phone, :updated_by_id],
                          :version_field => :version,
                          :track_create   =>  true,
                          :track_update   =>  true,
                          :track_destroy => true

  mongoid_userstamp user_model: 'User'

  def self.search(name_or_phone_str) # TODO optimize
    name_matches = Patient.where name: name_or_phone_str
    primary_matches = Patient.where primary_phone: name_or_phone_str
    secondary_matches = Patient.where secondary_phone: name_or_phone_str
    (name_matches | primary_matches | secondary_matches)
  end
end
