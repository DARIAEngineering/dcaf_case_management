# Representation of non-monetary assistance coordinated for a patient.
class PracticalSupport < ApplicationRecord
  acts_as_tenant :fund

  # Concerns
  include PaperTrailable

  # Relationships
  belongs_to :can_support, polymorphic: true

  # Validations
  validates :source, :support_type, presence: true
  validates :support_type, uniqueness: { scope: :can_support }
  validates :amount, 
              allow_nil: true,
              numericality: { only_integer: true, greater_than: 0 }
end
