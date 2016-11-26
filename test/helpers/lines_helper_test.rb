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
  end
end
