# Represents a case manager's call list state.
class CallList < ApplicationRecord
  # Relationships
  belongs_to :user
  belongs_to :patient

  # Validations
  validates :user, uniqueness: { scope: :patient } 
  validates :order_key, presence: true
end
