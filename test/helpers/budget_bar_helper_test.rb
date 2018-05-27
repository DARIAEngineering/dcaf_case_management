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
      assert_equal 'width: 10%', progress_bar_width(135)
    end
  end

  describe 'budget bar expenditure content' do
    before { @patient_hash = create(:patient).to_simplified_patient }

    it 'should return ???' do
      fail
    end
  end

  describe 'budget bar remaining' do
    before { @expenditures = Patient.pledged_status_summary }

    it 'should return an int' do
      assert_equal 1000,
                   budget_bar_remaining(@expenditures, 1000)
    end
  end
end
