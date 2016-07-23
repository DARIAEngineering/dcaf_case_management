require 'test_helper'

class WelcomeMessageHelperTest < ActionView::TestCase
  describe 'random welcome message' do
    it 'should return a string' do
      assert random_welcome_message.is_a? String
    end
  end
end
