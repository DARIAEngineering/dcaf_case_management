# Methods related to displaying attributes on the patient model
module AttributeDisplayable
  extend ActiveSupport::Concern

  def primary_phone_display
    return nil unless primary_phone.present?
    "#{primary_phone[0..2]}-#{primary_phone[3..5]}-#{primary_phone[6..9]}"
  end

  def other_phone_display
    return nil unless other_phone.present?
    "#{other_phone[0..2]}-#{other_phone[3..5]}-#{other_phone[6..9]}"
  end

  def appointment_date_display
    return nil unless appointment_date.present?
    "#{appointment_date.strftime("%m/%d/%Y")}"
  end

  def procedure_date_display
    return nil unless fulfillment.procedure_date.present?
    "#{fulfillment.procedure_date}"
  end
end
