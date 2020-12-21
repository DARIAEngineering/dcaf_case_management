# Convenience methods consumed in the dashboards controller index view
module DashboardsHelper
  def date_range(date: Time.zone.now)
    if (Config.start_day == :monthly )
      month_range(date: date)
    else
      week_range(date: date)
    end
  end

  def month_range(date: Time.zone.now)
    month_start = date.beginning_of_month
    month_end = date.end_of_month
    month_start_string = l month_start, format: '%B %-d'
    month_end_string = l month_end, format: '%-d'
    "#{month_start_string} - #{month_end_string}"
  end

  def week_range(date: Time.zone.now)
    start_day = Config.start_day
    week_start = date.beginning_of_week start_day
    week_end = date.end_of_week start_day
    week_start_string = l week_start, format: '%B %-d'
    week_end_string = if week_start.month == week_end.month
                        l week_end, format: '%-d'
                      else
                        l week_end, format: '%B %-d'
                      end
    "#{week_start_string} - #{week_end_string}"
  end
end
