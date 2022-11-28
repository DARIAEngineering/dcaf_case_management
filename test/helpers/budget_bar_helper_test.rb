require 'test_helper'

class BudgetBarHelperTest < ActionView::TestCase
  include ERB::Util

  describe 'progress bar color' do
    it 'should spit out correct color class based on type' do
      assert_equal 'bg-warning', progress_bar_color(:pledged)
      assert_equal 'bg-success', progress_bar_color(:sent)
    end
  end

  describe 'progress bar width' do
    it 'should accurately percentify width based on budget' do
      assert_equal 'width: 10%', progress_bar_width(100)
    end
  end

  describe 'budget bar expenditure content' do
    before do
      @patient_hash = {
        id: 123,
        appointment_date: 2.days.from_now,
        fund_pledge: 100,
        name: 'Friend Ship'
      }
    end

    it 'should return a link and appointment if set' do
      content = budget_bar_expenditure_content @patient_hash
      assert_match @patient_hash[:name], content
      assert_match @patient_hash[:appointment_date].display_date, content
    end

    it 'should accommodate no appt date' do
      @patient_hash[:appointment_date] = nil
      content = budget_bar_expenditure_content @patient_hash
      assert_match @patient_hash[:name], content
      assert_match 'no appt date', content
    end
  end

  describe 'budget bar statistics' do
    before do
      @expenditures = {
        :sent =>
          [{fund_pledge: 10},
           {fund_pledge: 20}],
        :pledged =>
          [{fund_pledge: 40}]
      }

      @limit = 1000
    end

    it 'should return an int & calculate remainder' do
      assert_equal 930,
                   budget_bar_remaining(@expenditures, @limit)
    end

    it 'should calculate statistics' do
      assert_equal "$70 spent (3 patients, 7%)",
          budget_bar_statistic('spent', @expenditures.values.flatten,
                               limit: 1000,
                               show_aggregate_statistics: true)
    end

    it 'should calculate remainder string' do
      assert_equal "$930 remaining (93%)",
          budget_bar_statistic_builder(
            name: 'remaining',
            amount: budget_bar_remaining(@expenditures, @limit),
            count: nil,
            limit: @limit,
            show_aggregate_statistics: true)
    end

    it 'should properly sum fund pledges' do
      # flattened should sum all
      assert_equal 70, sum_fund_pledges(@expenditures.values.flatten)

      # just one type should only sum that type
      assert_equal 30, sum_fund_pledges(@expenditures[:sent])
      assert_equal 40, sum_fund_pledges(@expenditures[:pledged])

      # check nil case - should return 0
      @expenditures[:sent] = []
      assert_equal 0, sum_fund_pledges(@expenditures[:sent])
      assert_equal 40, sum_fund_pledges(@expenditures.values.flatten)

      @expenditures[:pledged] = []
      assert_equal 0, sum_fund_pledges(@expenditures.values.flatten)
    end
  end
end
