require 'test_helper'

class PledgesHelperTest < ActionView::TestCase
  describe 'convenience methods' do
    describe 'submit_pledge_button' do
      it 'should return a span tag' do
        assert_match /span/, submit_pledge_button
        assert_match /Submit pledge/, submit_pledge_button
      end
    end
  end
end
