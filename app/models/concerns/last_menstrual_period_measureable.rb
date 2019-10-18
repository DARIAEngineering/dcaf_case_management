# Methods pertaining to last menstrual period calculation
module LastMenstrualPeriodMeasureable
  extend ActiveSupport::Concern

  def last_menstrual_period_at_appt_weeks
    return nil unless has_lmp? && appointment_date
    lmp = last_menstrual_period_on_date appointment_date
    (lmp / 7).to_i
  end

  def last_menstrual_period_at_appt_days
    return nil unless has_lmp? && appointment_date
    lmp = last_menstrual_period_on_date appointment_date
    (lmp % 7).to_i
  end

  def last_menstrual_period_now_weeks
    return nil unless has_lmp?
    (last_menstrual_period_now / 7).to_i
  end

  def last_menstrual_period_now_days
    return nil unless has_lmp?
    (last_menstrual_period_now % 7).to_i
  end

  private

  def has_lmp?
    initial_call_date && last_menstrual_period_weeks
  end

  def last_menstrual_period_now
    return nil unless has_lmp?
    if appointment_date && appointment_date < Time.zone.today
      last_menstrual_period_on_date appointment_date
    else
      last_menstrual_period_on_date Time.zone.today
    end
  end

  def last_menstrual_period_on_date(date)
    return nil unless has_lmp?
    weeks = 7 * (last_menstrual_period_weeks || 0)
    days = (last_menstrual_period_days || 0)
    current_lmp_in_days = (date - initial_call_date) + weeks + days
    if current_lmp_in_days > 280
      return 280
    else
      current_lmp_in_days
    end
  end
end
