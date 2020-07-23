# An object representing non-monetary assistance to patients,
# either by this fund or other stakeholders.
class PracticalSupport < ApplicationRecord
  # Relationships
  belongs_to :can_support, polymorphic: true
end
