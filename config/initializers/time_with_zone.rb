# Extends ActiveSupport::TimeWithZone class with convenience methods
module ActiveSupport
  class TimeWithZone
    def display_date
      tz = Config.time_zone || Rails.application.config.time_zone
      in_time_zone(tz).strftime("%m/%d/%Y")
    end

    def display_time
      tz = Config.time_zone || Rails.application.config.time_zone
      in_time_zone(tz).strftime("%-l:%M %P")
    end
  end
end