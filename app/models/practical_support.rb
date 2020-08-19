# An object representing non-monetary assistance to patients,
# either by this fund or other stakeholders.
class PracticalSupport < ApplicationRecord
  # Concerns
  include HistoryTrackable

  # Relationships
  belongs_to :can_support, polymorphic: true

  # Validations
  validates :source, :support_type, presence: true
  validates :support_type, uniqueness: { scope: :can_support }
end
