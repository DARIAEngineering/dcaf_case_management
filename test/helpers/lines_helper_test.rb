require 'test_helper'

class LinesHelperTest < ActionView::TestCase
  include ERB::Util

  describe 'convenience methods' do
    before do
      @lines = [
        create(:line, name: 'DC'),
        create(:line, name: 'MD'),
        create(:line, name: 'VA')
      ]
    end

    it 'should return current line' do
      assert_nil current_line
      assert_nil current_line_display

      @lines.each do |line|
        session[:line_id] = line.id
        session[:line_name] = line.name
        assert_equal current_line_display,
                     "<li><span class=\"nav-link navbar-text-alt\">Your current line: #{session[:line_name]}</span></li>"
        assert_equal current_line, line
      end
    end
  end
end
