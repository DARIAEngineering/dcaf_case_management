class Note
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History

  field :notes, type: String
  embedded_in :pregnancy
end
