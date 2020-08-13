# Bridge class between patient and user.
class CallList < ApplicationRecord
  # Relationships
  belongs_to :user
  belongs_to :patient

  # Validations
  validates :user, uniqueness: { scope: :patient }
end
