# Object representing money from organizations that aren't the fund or NAF.
# For primary fund pledges or NAF pledges, see the patient model.
class ExternalPledge < ApplicationRecord
  has_paper_trail

  # Relationships
  belongs_to :can_pledge, polymorphic: true

  # Scopes
  # TODO maybe remove active?
  default_scope -> { where(active: true) }
  scope :active, -> { where(active: true) }

  # Validations
  validates :created_by_id, :source, :amount, presence: true
  validates :source, uniqueness: { scope: :active }
end
