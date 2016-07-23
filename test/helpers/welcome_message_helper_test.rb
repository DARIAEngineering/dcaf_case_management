require 'test_helper'

class WelcomeMessageHelperTest < ActionView::TestCase
  describe 'random welcome message' do
    it 'should return a string' do
      assert random_welcome_message.is_a? String
    end

    it 'should be sourced entirely of strings' do
      send(:welcome_messages).each do |msg|
        assert msg.is_a? String
      end
    end
  end
end
