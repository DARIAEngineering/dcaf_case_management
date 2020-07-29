# A case manager's log of their interactions with a patient.
class Note < ApplicationRecord
  has_paper_trail

  # Relationships
  belongs_to :patients

  # Validations
  validates :created_by_id, :full_text, presence: true
end
