# Methods relating to inferring patient status
module StatusHelper
  STATUSES = {
    no_contact: 'No Contact Made',
    needs_appt: 'Needs Appointment',
    fundraising: 'Fundraising',
    pledge_sent: 'Pledge Sent',
    pledge_paid: 'Pledge Paid',
    resolved: 'Resolved Without DCAF',
    dropoff: 'Patient Has dropped Off'
  }.freeze

  def status
    return STATUSES[:dropoff] if number_of_days_since_last_call > 120
    return STATUSES[:resolved] if pregnancy.resolved_without_dcaf?
    return STATUSES[:pledge_sent] if pregnancy.pledge_sent?
    return STATUSES[:no_contact] if not contact_made?
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
end
