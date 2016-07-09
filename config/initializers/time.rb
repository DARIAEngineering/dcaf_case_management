# Extends time class with convenience methods
class Time
  def display_date
    getlocal.strftime("%Y-%m-%d")
  end

  def display_time
    getlocal.strftime("%-l:%M %P")
  end

  def display_timestamp
    "#{display_date} #{display_time}"
  end
end
