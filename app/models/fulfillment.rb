# Indicator that a pledge by the primary fund was cashed in,
# which in turn indicates that the patient used our pledged money.
class Fulfillment < ApplicationRecord
  acts_as_tenant :fund

  # Concerns
  include PaperTrailable

  # Relationships
  belongs_to :can_fulfill, polymorphic: true

  # Validations
  validates :fund_payout, :gestation_at_procedure, numericality: { only_integer: true,
                                                                   allow_nil: true,
                                                                   greater_than_or_equal_to: 0 }
  validates :check_number, length: { maximum: 150 }

  # Methods
  def gestation_at_procedure_display
    I18n.t('accountants.table_content.weeks_at_procedure_display', gestation: gestation_at_procedure) if gestation_at_procedure.present?
  end
end
