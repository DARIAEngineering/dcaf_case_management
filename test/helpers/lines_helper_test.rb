require 'test_helper'

class LinesHelperTest < ActionView::TestCase
  include ERB::Util

  describe 'convenience methods' do
    it 'should spit out an array of available lines' do
      assert_equal lines, %w(DC MD VA)
    end

    it 'should return current line' do
      assert_nil current_line

      %w(DC MD VA).each do |state|
        session[:line] = state
        assert_equal current_line, "Line: #{state}"
      end
    end

    it 'should split current lines from string' do
      line_strings = 'TX, WV'
      assert_equal %w(TX WV), send(:split_and_strip, line_strings)
    end
  end
end
