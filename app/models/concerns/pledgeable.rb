# Methods pertaining to pledges or pledge validation
module Pledgeable
  extend ActiveSupport::Concern

  def pledge_info_present?
    pledge_info_presence
    errors.messages.present?
  end

  def pledge_info_errors
    errors.messages.values.flatten.uniq
  end

  private

  def updating_pledge_sent?
    pledge_sent == true
  end

  def pledge_info_presence
    errors.add(:pledge_sent, I18n.t('patient.pledge.errors.blank_fund', fund: ActsAsTenant.current_tenant.name)) if fund_pledge.blank?
    errors.add(:pledge_sent, I18n.t('patient.pledge.errors.blank_patient')) if name.blank?
    errors.add(:pledge_sent, I18n.t('patient.pledge.errors.blank_clinic')) if clinic.blank?
    errors.add(:pledge_sent, I18n.t('patient.pledge.errors.blank_appt')) if appointment_date.blank?
  end
end
