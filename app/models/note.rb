class Note < ApplicationRecord
  # Relationships
  belongs_to :patients

  # Validations
  validates :created_by_id, :full_text, presence: true
end
