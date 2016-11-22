require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  include ERB::Util

  describe 'convenience methods' do
    it 'should spit out an array of available lines' do
      assert_equal lines, %w(DC MD VA)
    end
  end
end
