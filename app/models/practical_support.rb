# Representation of non-monetary assistance coordinated for a patient.
class PracticalSupport < ApplicationRecord
  include ActionView::Helpers::NumberHelper

  acts_as_tenant :fund

  encrypts :attachment_url

  # Concerns
  include PaperTrailable

  # Relationships
  belongs_to :can_support, polymorphic: true

  # Validations
  validates :source, :support_type, presence: true, length: { maximum: 150 }
  validates :amount,
            allow_nil: true,
            numericality: { greater_than_or_equal_to: 0 }

  def display_text
    content = [support_type, "from #{source}"]
    content.push("for #{number_to_currency(amount)}") if amount.present?
    content.push('(confirmed)') if confirmed?
    content.push("on #{support_date.display_date}") if support_date.present?
    content.join(' ')
  end
end
