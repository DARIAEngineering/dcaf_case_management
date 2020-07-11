class PracticalSupport < MongoPracticalSupport
  # Validations
  validates :created_by_id, :source, :support_type, presence: true
  validates :support_type, uniqueness: true
end
