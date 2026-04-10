require 'test_helper'

class NotificationsHelperTest < ActionView::TestCase
  describe 'notification_badge_class' do
    it 'should return correct badge class for each notification type' do
      assert_equal 'info', notification_badge_class('info')
      assert_equal 'warning', notification_badge_class('follow_up')
      assert_equal 'secondary', notification_badge_class('stale_patient')
      assert_equal 'primary', notification_badge_class('handoff')
      assert_equal 'danger', notification_badge_class('overdue_support')
      assert_equal 'dark', notification_badge_class('system')
    end

    it 'should default to info for unknown types' do
      assert_equal 'info', notification_badge_class('unknown')
      assert_equal 'info', notification_badge_class(nil)
    end

    it 'should cover all valid notification types' do
      valid_types = %w[info follow_up stale_patient handoff overdue_support system]
      valid_types.each do |type|
        assert NotificationsHelper::BADGE_CLASSES.key?(type),
          "BADGE_CLASSES should have an entry for #{type}"
      end
    end
  end
end
