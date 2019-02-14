class PracticalSupport
  include Mongoid::Document
  field :support_type, type: String
  field :confirmed, type: Mongoid::Boolean
  field :source, type: String
end
