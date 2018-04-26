# Methods pertaining to determining a patient's displayed status
module Statusable
  extend ActiveSupport::Concern

  STATUSES = {
    no_contact: { key: 'No Contact Made', help_text: 'A patient has initiated contact, but nobody from the fund has spoken to them yet.' },
    needs_appt: { key: 'Needs Appointment', help_text: 'The patient has spoken to the fund, but has not yet set an appointment date with a clinic.' },
    fundraising: { key: 'Fundraising', help_text: 'The patient has an appointment date, and is working on raising funds.' },
    pledge_sent: { key: 'Pledge Sent', help_text: 'A case manager has sent a pledge to the clinic on behalf of the patient.' },
    pledge_paid: { key: 'Pledge Paid', help_text: 'Accountant has paid back the clinic for the pledge.' },
    pledge_unfulfilled: { key: 'Pledge Not Fulfilled', help_text: 'Patient had a pledge sent 150+ days ago but has not cashed it.' },
    fulfilled: { key: 'Pledge Fulfilled', help_text: 'Patient has been marked fulfilled.' },
    dropoff: { key: 'Probable Dropoff', help_text: 'Patient has not been heard from in 120+ days.' },
    resolved: { key: "Resolved Without #{FUND}", help_text: 'Patient has decided to not involve the fund in their plans.'}
  }.freeze

  def status
    return STATUSES[:fulfilled][:key] if fulfillment.fulfilled?
    return STATUSES[:resolved][:key] if resolved_without_fund?
    return STATUSES[:pledge_unfulfilled][:key] if days_since_pledge_sent > 150
    return STATUSES[:pledge_sent][:key] if pledge_sent?
    return STATUSES[:dropoff][:key] if days_since_last_call > 120
    return STATUSES[:no_contact][:key] unless contact_made?
    return STATUSES[:fundraising][:key] if appointment_date
    STATUSES[:needs_appt][:key]
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

  def days_since_pledge_sent
    return 0 if !pledge_sent
    return 0 if !pledge_sent_at
    days_since_pledge_sent = (DateTime.now.in_time_zone.to_date - pledge_sent_at.to_date).to_i
    days_since_pledge_sent
  end
end
