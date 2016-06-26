class Pledge
  include Auditable
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

  # Relationships
  embedded_in :pregnancy

  # Fields
  field :pledge_type, type: String # soft/patient/naf/other/final_dcaf
  field :amount, type: Integer
  field :other_pledge_identifier, type: String
  field :sent, type: DateTime # validate presence when type is final
  field :sent_by, type: String # validate presence when type is final
  field :paid, type: Boolean # validate presence when type is final
  field :paid_date, type: DateTime # validate presence when type is final

  # Validations
  validates :created_by, :pledge_type, presence: true

end
