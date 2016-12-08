require 'test_helper'

class ChangeLogHelperTest < ActionView::TestCase
  describe 'safe join convenience method' do
    it 'should work' do
      assert_equal safe_join_fields(%w(yolo goat)),
                   'yolo<br />goat'
    end
  end
end
