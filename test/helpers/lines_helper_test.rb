require 'test_helper'

class LinesHelperTest < ActionView::TestCase
  include ERB::Util

  describe 'convenience methods' do
    it 'should return empty if not set' do
      assert_nil current_line
      assert_nil current_line_display
    end

    it 'should show a link if 2+ lines' do
      @lines = [
        create(:line, name: 'DC'),
        create(:line, name: 'MD'),
        create(:line, name: 'VA')
      ]

      @lines.each do |line|
        session[:line_id] = line.id
        session[:line_name] = line.name
        assert_equal current_line_display,
                     "<li><a class=\"nav-link navbar-text-alt\" href=\"/lines/new\">Your current line: #{session[:line_name]}</a></li>"
        assert_equal current_line, line
      end
    end

    it 'should show text if just one line' do
      line = create(:line, name: 'DC')
      session[:line_id] = line.id
      session[:line_name] = line.name
      assert_equal current_line_display,
                    "<li><span class=\"nav-link navbar-text-alt\">Your current line: #{session[:line_name]}</span></li>"
      assert_equal current_line, line
    end
  end
end
