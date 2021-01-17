# Object representing a patient's call list.
class CallList
  include Mongoid::Document
  include Mongoid::Timestamps

  # Relationships
  belongs_to :user
  belongs_to :patient

  # Fields
  field :order_key, type: Integer
  field :line, type: String

  # Validations
  validates :order_key, :line, presence: true
  validates :patient, uniqueness: { scope: :user }

  # Indices
  index line: 1
end
