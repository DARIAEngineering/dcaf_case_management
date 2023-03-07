require 'test_helper'

class TimeWithZoneTest < ActiveSupport::TestCase
  # The system time of the Rails app is set to ET

  describe "display_date" do
    it "converts a time_with_zone stored in system time to the configured time zone and displays" do
      config = Config.create(config_key: :time_zone, config_value: { options: ['Eastern'] })
      time = Time.zone.local(2023, 2, 10, 1, 30, 45)
      
      assert_equal "02/10/2023", time.display_date

      config.update(config_value: { options: ['Central'] })
      assert_equal "02/10/2023", time.display_date

      config.update(config_value: { options: ['Mountain'] })
      assert_equal "02/09/2023", time.display_date

      config.update(config_value: { options: ['Pacific'] })
      assert_equal "02/09/2023", time.display_date
    end
  end

  describe "display_time" do
    it "converts a time_with_zone stored in system time to the configured time zone and displays" do
      config = Config.create(config_key: :time_zone, config_value: { options: ['Eastern'] })
      time = Time.zone.local(2023, 2, 10, 1, 30, 45)
      
      assert_equal "1:30 am", time.display_time

      config.update(config_value: { options: ['Central'] })
      assert_equal "12:30 am", time.display_time

      config.update(config_value: { options: ['Mountain'] })
      assert_equal "11:30 pm", time.display_time

      config.update(config_value: { options: ['Pacific'] })
      assert_equal "10:30 pm", time.display_time
    end
  end
end