require 'test_helper'

class BudgetBarHelperTest < ActionView::TestCase
  include ERB::Util

  describe 'progress bar color' do
    it 'should spit out correct color class based on type' do
      assert_equal 'progress-bar-warning', progress_bar_color(:pledged)
      assert_equal 'progress-bar-success', progress_bar_color(:sent)
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

  describe 'budget bar remaining' do
    before { @expenditures = Patient.pledged_status_summary(:DC) }

    it 'should return an int' do
      assert_equal 1000,
                   budget_bar_remaining(@expenditures, 1000)
    end
  end
end
