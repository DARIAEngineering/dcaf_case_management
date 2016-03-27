class Note
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History

  embedded_in :pregnancy

  field :notes, type: String
end
