module LastMenstrualPeriodHelper
  # last menstrual period calculator methods
  def last_menstrual_period_now
    return nil unless last_menstrual_period_at_intake
    "#{(last_menstrual_period_at_intake / 7).round} weeks, " \
    "#{(last_menstrual_period_at_intake % 7).to_i} days"
  end

  def last_menstrual_period_now_short
    last_menstrual_period_now.to_s.gsub(' weeks,', 'w').gsub(' days', 'd')
  end

  private

  def last_menstrual_period_at_intake
    last_menstrual_period_on_date Date.today
  end

  def last_menstrual_period_on_date(date)
    return nil unless initial_call_date && last_menstrual_period_weeks
    weeks = 7 * (last_menstrual_period_weeks || 0)
    days = (last_menstrual_period_days || 0)
    (initial_call_date.to_date + weeks + days) - date
  end
end
