require 'test_helper'

class LastMenstrualPeriodHelperTest < ActionView::TestCase
  before do
    @user = create :user
    @patient = create :patient, created_by: @user
    @pregnancy = create :pregnancy,
                        last_menstrual_period_weeks: 9,
                        last_menstrual_period_days: 2,
                        initial_call_date: 2.days.ago,
                        created_by: @user
  end

  describe 'last_menstrual_period_display' do
    it 'should return nil if LMP weeks is not set' do
      @pregnancy.last_menstrual_period_weeks = nil
      assert_nil @pregnancy.last_menstrual_period_display
    end

    it 'should return LMP in weeks and days' do
      assert_equal @pregnancy.last_menstrual_period_display, '9 weeks, 4 days'
    end
  end

  describe 'last_menstrual_period_display_short' do
    it 'should return nil if LMP weeks is not set' do
      @pregnancy.last_menstrual_period_weeks = nil
      assert_nil @pregnancy.last_menstrual_period_display_short
    end

    it 'should return shorter LMP in weeks and days' do
      assert_equal @pregnancy.last_menstrual_period_display_short, '9w 4d'
    end
  end

  describe 'last_menstrual_period_now' do
    it 'should return nil if LMP weeks is not set' do
      @pregnancy.last_menstrual_period_weeks = nil
      assert_nil @pregnancy.send(:last_menstrual_period_now)
    end

    it 'should be equivalent to LMP on date - Time.zone.today' do
      assert_equal  @pregnancy.send(:last_menstrual_period_now),
                    @pregnancy.send(:last_menstrual_period_on_date, Time.zone.today)
    end
  end

  describe 'last_menstrual_period_on_date' do
    it 'should nil out if LMP weeks is not set' do
      @pregnancy.last_menstrual_period_weeks = nil
      assert_nil @pregnancy.send(:last_menstrual_period_on_date, Time.zone.today)
    end

    it 'should accurately calculate LMP on a given date' do
      assert_equal @pregnancy.send(:last_menstrual_period_on_date, Time.zone.today), 67
      assert_equal @pregnancy.send(:last_menstrual_period_on_date, 5.days.from_now.to_date), 72

      @pregnancy.initial_call_date = 4.days.ago
      assert_equal @pregnancy.send(:last_menstrual_period_on_date, Time.zone.today), 69

      @pregnancy.last_menstrual_period_weeks = 10
      assert_equal @pregnancy.send(:last_menstrual_period_on_date, Time.zone.today), 76

      @pregnancy.last_menstrual_period_days = 6
      assert_equal @pregnancy.send(:last_menstrual_period_on_date, Time.zone.today), 80
    end
  end
end
