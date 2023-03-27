# Representation of non-monetary assistance coordinated for a patient.
class PracticalSupport < ApplicationRecord
  acts_as_tenant :fund

  # Concerns
  include PaperTrailable

  # Relationships
  belongs_to :can_support, polymorphic: true

  # Validations
  validates :source, :support_type, presence: true, length: { maximum: 150 }
  validates :amount,
            allow_nil: true,
            numericality: { greater_than_or_equal_to: 0 }
end
