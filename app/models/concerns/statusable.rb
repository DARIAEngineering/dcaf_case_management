# Methods pertaining to determining a patient's displayed status
module Statusable
  extend ActiveSupport::Concern

  STATUSES = {
    no_contact: { key: I18n.t('patient.status.key.no_contact'),
                  help_text: I18n.t('patient.status.help.no_contact')},
    needs_appt: { key: I18n.t('patient.status.key.needs_appt'),
                  help_text: I18n.t('patient.status.help.needs_appt')},
    fundraising: { key: I18n.t('patient.status.key.fundraising'),
                   help_text: I18n.t('patient.status.help.fundraising')},
    pledge_sent: { key: I18n.t('patient.status.key.pledge_sent'),
                   help_text: I18n.t('patient.status.help.pledge_sent')},
    pledge_paid: { key: I18n.t('patient.status.key.pledge_paid'),
                   help_text: I18n.t('patient.status.help.pledge_paid')},
    pledge_unfulfilled: { key: I18n.t('patient.status.key.pledge_unfulfilled'),
                          help_text: I18n.t('patient.status.help.pledge_unfulfilled')},
    fulfilled: { key: I18n.t('patient.status.key.fulfilled'),
                 help_text: I18n.t('patient.status.help.fulfilled')},
    dropoff: { key: I18n.t('patient.status.key.dropoff'),
               help_text: I18n.t('patient.status.help.dropoff')},
    resolved: { key: I18n.t('patient.status.key.resolved', fund: FUND),
                help_text: I18n.t('patient.status.help.resolved')}
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
