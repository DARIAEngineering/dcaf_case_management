require 'test_helper'

class DashboardsHelperTest < ActionView::TestCase
  before do
    @date_1 = DateTime.new(2016, 5, 21).in_time_zone
    @date_2 = DateTime.new(2016, 5, 31).in_time_zone
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

  describe 'plus sign glyphicon method' do
    it 'should return nil if the text is under 40 char' do
      under_40_char = 'yolo goat'
      assert_nil plus_sign_glyphicon under_40_char
    end

    it 'should return a glyphicon if the text is over 40 char' do
      over_40_char = 'this is 40 character or so cats are great so fluffy'
      refute_nil plus_sign_glyphicon over_40_char
    end
  end

  describe 'voicemail_options' do
    it 'should return an array based on pregnancy.voicemail_options' do
      Patient::VOICEMAIL_PREFERENCE.each do |pref|
        refute_empty voicemail_options.select { |opt| opt[1] == pref }
      end
    end
  end
end
