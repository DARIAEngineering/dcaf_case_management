require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = create :user
  end

  # devise handles most of this

  describe 'basic validations' do 
    it 'should be able to build an object' do 
      assert @user.valid? 
    end

    %w(email name).each do |attribute|
      it "should require content in #{attribute}" do 
        @user[attribute.to_sym] = nil 
        assert_not @user.valid? 
        assert_equal "can't be blank", @user.errors.messages[attribute.to_sym].first
      end
    end
  end
end
