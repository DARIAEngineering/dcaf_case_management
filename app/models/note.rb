# A case manager's log of their interactions with a patient.
class Note < ApplicationRecord
  has_paper_trail
  include HistoryTrackable

  # Relationships
  belongs_to :patients

  # Validations
  validates :full_text, presence: true
end
