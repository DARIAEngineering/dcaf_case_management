require 'test_helper'

class DashboardsHelperTest < ActionView::TestCase
  before do
    @date_1 = DateTime.new.in_time_zone(2016, 5, 21)
    @date_2 = DateTime.new.in_time_zone(2016, 5, 31)
    @monday_start = :monday
  end

  describe 'week_range method' do
    it 'should return correct date range when start and end months are same' do
      expected = 'May 16 - 22'
      assert_equal expected, week_range(date: @date_1, start_day: @monday_start)
    end

    it 'should return correct date range when start and end months differ' do
      expected = 'May 30 - June 5'
      assert_equal expected, week_range(date: @date_2, start_day: @monday_start)
    end
  end
end
