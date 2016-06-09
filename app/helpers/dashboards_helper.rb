module DashboardsHelper
  def week_range(date: DateTime.now, start_day: :monday)
    week_start = date.beginning_of_week(start_day)
    week_end = date.end_of_week(start_day)
    week_start_string = week_start.strftime('%B %-d')
    week_end_string = week_start.month == week_end.month ? week_end.strftime('%-d') : week_end.strftime('%B %-d')
    "#{week_start_string} - #{week_end_string}"
  end
end
