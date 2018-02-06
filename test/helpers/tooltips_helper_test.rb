require 'test_helper'

# For testing the tooltips functions
class TooltipsHelperTest < ActionView::TestCase
  describe 'drop-in method' do
    it 'should return a span with tooltip text' do
      content = tooltip_shell 'yolo goat'

      assert_match /yolo goat/, content.to_s
      assert_match /span/, content.to_s
      assert_match /data-toggle/, content.to_s
      assert_match /daria-tooltip/, content.to_s
    end
  end

  describe 'help_text functions' do
    # Everything's okay alarms -- no need to test contents
    %i[your_call_list_help_text your_completed_calls_help_text
       urgent_cases_help_text status_help_text
       record_new_external_pledge_help_text
       resolved_without_fund_help_text].each do |func|
      it "should return a string - #{func}" do
        assert_operator send(func).length, :>, 10
      end
    end
  end
end
