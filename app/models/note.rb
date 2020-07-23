# A case manager's log of their interactions with a patient.
class Note < ApplicationRecord
  # Relationships
  belongs_to :patients

  # Validations
  validates :created_by_id, :full_text, presence: true
end
