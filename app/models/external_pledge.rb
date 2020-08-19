# Object representing money from organizations that aren't the fund or NAF.
# For primary fund pledges or NAF pledges, see the patient model.
class ExternalPledge < ApplicationRecord
  # Concerns
  include HistoryTrackable

  # Relationships
  belongs_to :can_pledge, polymorphic: true

  # Scopes
  # TODO maybe remove active?
  default_scope -> { where(active: true) }
  scope :active, -> { where(active: true) }

  # Validations
  validates :source, :amount, presence: true
  validates :source, uniqueness: { scope: [:active, :can_pledge] }
end
