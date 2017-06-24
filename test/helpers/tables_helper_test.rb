require 'test_helper'

class TablesHelperTest < ActionView::TestCase
  include ERB::Util

  describe 'autosortable methods' do
    describe 'th_autosortable' do
      it 'should choke on a bad datatype' do
        assert_raises RuntimeError do
          th_autosortable 'Status', 'date', {}
        end
      end

      it 'should return a column header' do
        th_tag = th_autosortable 'Status', 'string-ins', autosortable: true
        [/th/, /data-sort="string-ins"/, /span/, /arrow/].each do |regexp|
          assert_match regexp, th_tag
        end
      end
    end
  end
end
