class PracticalSupport < ApplicationRecord
  # Relationships
  belongs_to :can_support, polymorphic: true
end
