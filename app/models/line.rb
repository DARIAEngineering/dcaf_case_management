class Line < ApplicationRecord
  acts_as_tenant :fund

  # Validations
  validates_uniqueness_to_tenant :name
  validates :name, presence: true
end
