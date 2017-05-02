# last menstrual period calculator methods
module LastMenstrualPeriodHelper
  def last_menstrual_period_display
    return nil unless last_menstrual_period_now
    display_as_weeks last_menstrual_period_now
  end

  def last_menstrual_period_display_short
    return nil unless last_menstrual_period_now
    last_menstrual_period_display.to_s.gsub(' weeks,', 'w').gsub(' days', 'd')
  end

  def last_menstrual_period_at_appt
    return nil unless last_menstrual_period_now && patient.appointment_date
    lmp = last_menstrual_period_on_date patient.appointment_date
    display_as_weeks lmp
  end

  private

  def last_menstrual_period_now
    if patient.appointment_date && patient.appointment_date < Time.zone.today
      last_menstrual_period_on_date patient.appointment_date
    else
      last_menstrual_period_on_date Time.zone.today
    end
  end

  def last_menstrual_period_on_date(date)
    return nil unless patient.initial_call_date && last_menstrual_period_weeks
    weeks = 7 * (last_menstrual_period_weeks || 0)
    days = (last_menstrual_period_days || 0)
    if (date - patient.initial_call_date) + weeks + days > 280
      return 280
    else
      (date - patient.initial_call_date) + weeks + days
    end
  end

  def display_as_weeks(num)
    "#{(num / 7).floor} weeks, " \
    "#{(num % 7).to_i} days"
  end
end
