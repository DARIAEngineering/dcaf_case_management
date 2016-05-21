require 'test_helper'

class DashboardsHelperTest < ActionView::TestCase

  describe 'week_range method' do
    it 'should return current date range' do 
      first_day_of_week = :monday
      today = DateTime.now
      start_of_week_date = today.beginning_of_week(first_day_of_week).strftime("%B %d")
      end_of_week_date = today.end_of_week(first_day_of_week).strftime("%d")
      expected = "#{start_of_week_date} - #{end_of_week_date}"
      assert_equal expected, week_range
    end 
  end
end