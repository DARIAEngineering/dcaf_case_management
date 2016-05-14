class Clinic < Active Record ::Base
  include Auditable
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp
  

  belongs_to :pregnancy

  field :name, type: String
  field :street_address_1, type: String
  field :street_address_2, type: String
  field :city, type: String
  field :state, type: String # ennnnnnummmmerrrrattttttioonnn???????
  field :zip, type: String

end
