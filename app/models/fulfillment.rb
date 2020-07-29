# Indicator that a pledge by the primary fund was cashed in,
# which in turn indicates that the patient used our pledged money.
class Fulfillment < ApplicationRecord
  has_paper_trail

  # Relationships
  belongs_to :can_fulfill, polymorphic: true

  # Validations
  validates :created_by_id,
            presence: true

  # Methods
  def gestation_at_procedure_display
    I18n.t('accountants.table_content.weeks_at_procedure_display', gestation: gestation_at_procedure) if gestation_at_procedure.present?
  end  
end
