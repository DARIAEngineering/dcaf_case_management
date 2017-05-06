# Methods pertaining to last menstrual period calculation
module LastMenstrualPeriodMeasureable
  extend ActiveSupport::Concern

  def last_menstrual_period_display
    return nil unless _last_menstrual_period_now
    _display_as_weeks _last_menstrual_period_now
  end

  def last_menstrual_period_display_short
    return nil unless _last_menstrual_period_now
    last_menstrual_period_display.to_s.gsub(' weeks,', 'w').gsub(' days', 'd')
  end

  def last_menstrual_period_at_appt
    return nil unless _last_menstrual_period_now && appointment_date
    lmp = _last_menstrual_period_on_date appointment_date
    _display_as_weeks lmp
  end

  def _last_menstrual_period_now
    if appointment_date && appointment_date < Time.zone.today
      _last_menstrual_period_on_date appointment_date
    else
      _last_menstrual_period_on_date Time.zone.today
    end
  end

  def _last_menstrual_period_on_date(date)
    return nil unless initial_call_date && last_menstrual_period_weeks
    weeks = 7 * (last_menstrual_period_weeks || 0)
    days = (last_menstrual_period_days || 0)
    if (date - patient.initial_call_date) + weeks + days > 280
      return 280
    else
      (date - patient.initial_call_date) + weeks + days
    end
  end

  def _display_as_weeks(num)
    "#{(num / 7).floor} weeks, " \
    "#{(num % 7).to_i} days"
  end
end
