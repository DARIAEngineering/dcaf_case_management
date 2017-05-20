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
    errors.add(:pledge_sent, 'DCAF soft pledge field cannot be blank') if fund_pledge.blank?
    errors.add(:pledge_sent, 'Patient name cannot be blank') if name.blank?
    errors.add(:pledge_sent, 'Clinic name cannot be blank') if clinic.blank?
    errors.add(:pledge_sent, 'Appointment date cannot be blank') if appointment_date.blank?
  end
end
