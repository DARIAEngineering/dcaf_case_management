require 'test_helper'

class UsersHelperTest < ActionView::TestCase
  describe 'user role options' do
    it 'should return a span tag' do
      assert user_role_options.is_a? Array
    end
  end

  # TODO status helper
  # describe 'status helper' do
  #   before do
  #     @user = create :user, name: 'Locke'
  #   end
  #   it 'should return active' do
  #     assert_equal status(@user), 'Active'
  #   end
  #   it 'should return locked' do
  #     @user.lock_access!
  #     assert_equal status(@user), 'Locked'
  #   end
  # end
end
