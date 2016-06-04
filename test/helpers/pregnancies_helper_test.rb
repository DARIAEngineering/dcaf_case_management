require 'test_helper'

class PregnanciesHelperTest < ActionView::TestCase
  describe 'weeks_options' do
    it 'should pluralize properly' do
      assert_equal '1 week', weeks_options.first[0]
      assert_equal '2 weeks', weeks_options.second[0]
      assert_equal 1, weeks_options.select { |x| /week$/.match x[0] }.count
    end

    it 'should have 30 entries' do
      assert_equal 30, weeks_options.count
    end
  end

  describe 'days_options' do
    it 'should pluralize properly' do
      assert_equal '0 days', days_options.first[0]
      assert_equal '1 day', days_options.second[0]
      assert_equal '2 days', days_options.third[0]
      assert_equal 1, days_options.select { |x| /day$/.match x[0] }.count
    end

    it 'should have 7 entries' do
      assert_equal 7, days_options.count
    end
  end
end
