require 'test_helper'

# For testing the tooltips functions
class TooltipsHelperTest < ActionView::TestCase
  describe 'drop-in methods' do
    describe 'tooltip shell' do
      it 'should return a span with tooltip text' do
        content = tooltip_shell 'yolo goat'

        assert_match /yolo goat/, content.to_s
        assert_match /span/, content.to_s
        assert_match /data-toggle/, content.to_s
        assert_match /daria-tooltip/, content.to_s
      end
    end

    describe 'dashboard table content tooltip shell' do
      it 'should blank out on search_results' do
        assert_nil dashboard_table_content_tooltip_shell('search_results')
      end

      it 'should return the tooltip shell otherwise' do
        assert_equal tooltip_shell(call_list_help_text),
                     dashboard_table_content_tooltip_shell('call_list')
      end
    end
  end

  describe 'help_text functions' do
    # Everything's okay alarms -- no need to test contents
    %i[call_list_help_text completed_calls_help_text
       urgent_cases_help_text record_new_external_pledge_help_text
       resolved_without_fund_help_text referred_to_clinic_help_text
        budget_bar_help_text].each do |func|
      it "should return a string - #{func}" do
        assert_operator send(func).length, :>, 10
      end
    end
  end

  describe 'status_help_text content' do
    before do
      @patient = create :patient
    end

    it 'should return a string - status_help_text' do
      assert_match /No Contact Made/, status_help_text(@patient)
      assert_match /budget bar/, budget_bar_help_text
    end
  end
end
