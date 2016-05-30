class Patient<ActiveRecord::Base
  include Auditable
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

  has_many :pregnancies

  validates_presence_of :name, :primary_phone

  field :name, type: String # strip
  field :primary_phone, type: String 
  validates :primary_phone, length:{maximum:12}
  field :secondary_person, type: String
  field :secondary_phone, type: String 
  validates :secondary_phone, length:{maximum:12}

  def self.search(name_or_phone_str) # TODO: optimize
    name_matches = Patient.where name: name_or_phone_str
    primary_matches = Patient.where primary_phone: name_or_phone_str
    secondary_matches = Patient.where secondary_phone: name_or_phone_str
    (name_matches | primary_matches | secondary_matches)
  end
end
