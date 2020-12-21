# Object representing money from organizations that aren't the fund or NAF.
# For primary fund pledges or NAF pledges, see the patient model.
class ExternalPledge < ApplicationRecord
  # Concerns
  PaperTrailable

  # Relationships
  embedded_in :can_pledge, polymorphic: true

  default_scope -> { where(active: true) }
  scope :active, -> { where(active: true) }

  # Validations
  validates :source, :amount, presence: true
  validates :source, uniqueness: { scope: :active }
end
