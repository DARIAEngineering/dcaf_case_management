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
            limit: @limit)
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

  # ----- sum_fund_pledges edge cases -----

  describe 'sum_fund_pledges edge cases' do
    it 'returns 0 for nil input' do
      assert_equal 0, sum_fund_pledges(nil)
    end

    it 'returns 0 for empty array' do
      assert_equal 0, sum_fund_pledges([])
    end

    it 'handles a single pledge' do
      assert_equal 50, sum_fund_pledges([{ fund_pledge: 50 }])
    end

    it 'handles negative fund_pledge values' do
      pledges = [{ fund_pledge: -10 }, { fund_pledge: 30 }]
      assert_equal 20, sum_fund_pledges(pledges)
    end

    it 'handles very large fund_pledge values' do
      pledges = [{ fund_pledge: 999_999_999 }, { fund_pledge: 1 }]
      assert_equal 1_000_000_000, sum_fund_pledges(pledges)
    end

    it 'handles float fund_pledge values' do
      pledges = [{ fund_pledge: 10.50 }, { fund_pledge: 20.75 }]
      assert_in_delta 31.25, sum_fund_pledges(pledges), 0.001
    end

    it 'handles zero fund_pledge values' do
      pledges = [{ fund_pledge: 0 }, { fund_pledge: 0 }]
      assert_equal 0, sum_fund_pledges(pledges)
    end
  end

  # ----- budget_bar_remaining edge cases -----

  describe 'budget_bar_remaining edge cases' do
    it 'returns limit when expenditures is nil' do
      assert_equal 1000, budget_bar_remaining(nil, 1000)
    end

    it 'returns limit when expenditures has no :pledged or :sent keys' do
      assert_equal 500, budget_bar_remaining({}, 500)
    end

    it 'handles expenditures with only :pledged key (no :sent)' do
      expenditures = { pledged: [{ fund_pledge: 100 }] }
      assert_equal 400, budget_bar_remaining(expenditures, 500)
    end

    it 'handles expenditures with only :sent key (no :pledged)' do
      expenditures = { sent: [{ fund_pledge: 200 }] }
      assert_equal 300, budget_bar_remaining(expenditures, 500)
    end

    it 'can return negative remainder when expenditures exceed limit' do
      expenditures = {
        pledged: [{ fund_pledge: 600 }],
        sent: [{ fund_pledge: 600 }]
      }
      assert_equal(-200, budget_bar_remaining(expenditures, 1000))
    end

    it 'returns limit when both pledged and sent are empty arrays' do
      expenditures = { pledged: [], sent: [] }
      assert_equal 1000, budget_bar_remaining(expenditures, 1000)
    end

    it 'handles zero limit' do
      expenditures = { pledged: [{ fund_pledge: 50 }], sent: [] }
      assert_equal(-50, budget_bar_remaining(expenditures, 0))
    end

    it 'handles float fund_pledge values in remaining calculation' do
      expenditures = {
        pledged: [{ fund_pledge: 10.5 }],
        sent: [{ fund_pledge: 20.25 }]
      }
      assert_in_delta 469.25, budget_bar_remaining(expenditures, 500), 0.001
    end
  end

  # ----- progress_bar_color edge cases -----

  describe 'progress_bar_color edge cases' do
    it 'returns bg-warning for :pledged' do
      assert_equal 'bg-warning', progress_bar_color(:pledged)
    end

    it 'returns bg-success for :sent' do
      assert_equal 'bg-success', progress_bar_color(:sent)
    end

    it 'returns bg- prefix for any unknown type' do
      result = progress_bar_color(:unknown)
      assert_match(/^bg-/, result)
    end
  end

  # ----- progress_bar_width edge cases -----

  describe 'progress_bar_width edge cases' do
    it 'returns width: 0% when value is 0' do
      assert_equal 'width: 0%', progress_bar_width(0)
    end

    it 'returns width: 0% when cash_ceiling is 0 (avoids division by zero)' do
      assert_equal 'width: 0%', progress_bar_width(100, 0)
    end

    it 'handles value exceeding cash_ceiling (over 100%)' do
      result = progress_bar_width(2000)
      assert_match(/width: \d+%/, result)
    end
  end
end
