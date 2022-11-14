# A case manager's log of their interactions with a patient.
class Note < ApplicationRecord
  acts_as_tenant :fund

  # Concerns
  include PaperTrailable

  # Relationships
  belongs_to :patient

  # Validations
  validates :full_text, presence: true, length: { maximum: 4000 }
end
