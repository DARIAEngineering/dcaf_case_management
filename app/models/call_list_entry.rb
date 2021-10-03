# Object representing a patient's call list.
class CallListEntry < ApplicationRecord
  acts_as_tenant :fund

  # Relationships
  belongs_to :user
  belongs_to :patient

  # Validations
  validates :order_key, :line, presence: true
  validates_uniqueness_to_tenant :patient, scope: :user
end
