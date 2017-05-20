require 'test_helper'

class UsersHelperTest < ActionView::TestCase
  describe 'user role options' do
    it 'should return a span tag' do
      assert user_role_options.is_a? Array
    end
  end
end
