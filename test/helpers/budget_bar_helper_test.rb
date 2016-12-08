require 'test_helper'

class BudgetBarHelperTest < ActionView::TestCase
  include ERB::Util

  describe 'convenience methods' do
    it 'should spit out correct color class based on type' do
      assert_equal 'progress-bar-warning', progress_bar_color(:pledged)
      assert_equal 'progress-bar-success', progress_bar_color(:sent)
    end

    it 'should accurately percentify width based on budget' do
      assert_equal 'width: 10%', progress_bar_width(135)
    end
  end
end
