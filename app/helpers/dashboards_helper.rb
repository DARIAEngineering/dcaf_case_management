module DashboardsHelper

  def week_range
    today = DateTime.now
    week_start = today.beginning_of_week(:monday).strftime("%B %d")
    week_end = today.end_of_week(:monday).strftime("%d")
    "#{week_start} - #{week_end}"
  end
end
