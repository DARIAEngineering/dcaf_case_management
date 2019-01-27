require 'test_helper'

class ChangeLogHelperTest < ActionView::TestCase
  describe 'safe join convenience method' do
    it 'should work' do
      assert_equal safe_join_fields(%w(yolo goat)),
                   'yolo<br />goat'
    end
  end

  describe 'change_or_nil' do
    it 'should return field if field' do
      assert_equal 'yolo', change_or_nil('yolo')
    end

    it 'should return empty if nothing' do
      assert_equal 'empty', change_or_nil('')
      assert_equal 'empty', change_or_nil(nil)
    end
  end
end
