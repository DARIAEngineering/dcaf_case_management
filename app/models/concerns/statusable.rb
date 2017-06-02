# Methods pertaining to determining a patient's displayed status
module Statusable
  extend ActiveSupport::Concern

  STATUSES = {
    no_contact: 'No Contact Made',
    needs_appt: 'Needs Appointment',
    fundraising: 'Fundraising',
    pledge_sent: 'Pledge Sent',
    pledge_paid: 'Pledge Paid',
    dropoff: 'Probable dropoff',
    resolved: "Resolved Without #{FUND}"
  }.freeze

  def status
    return STATUSES[:resolved] if resolved_without_fund?
    return STATUSES[:pledge_sent] if pledge_sent?
    return STATUSES[:dropoff] if days_since_last_call > 120
    return STATUSES[:no_contact] unless contact_made?
    return STATUSES[:fundraising] if appointment_date
    STATUSES[:needs_appt]
  end

  private

  def contact_made?
    calls.each do |call|
      return true if call.status == 'Reached patient'
    end
    false
  end

  def days_since_last_call
    return 0 if calls.blank?
    days_since_last_call = (DateTime.now.in_time_zone.to_date - last_call.created_at.to_date).to_i
    days_since_last_call
  end
end
