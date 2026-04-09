require 'test_helper'

class NotificationTest < ActiveSupport::TestCase
  before do
    @user = create :user
  end

  describe 'validations' do
    it 'should be valid with required attributes' do
      notification = build :notification, user: @user
      assert notification.valid?
    end

    it 'should require title' do
      notification = build :notification, user: @user, title: nil
      refute notification.valid?
      assert notification.errors[:title].any?
    end

    it 'should require notification_type' do
      notification = build :notification, user: @user, notification_type: nil
      refute notification.valid?
    end

    it 'should validate notification_type inclusion' do
      %w[info follow_up stale_patient handoff overdue_support system].each do |type|
        notification = build :notification, user: @user, notification_type: type
        assert notification.valid?, "#{type} should be a valid notification_type"
      end

      notification = build :notification, user: @user, notification_type: 'invalid'
      refute notification.valid?
    end

    it 'should enforce title max length' do
      notification = build :notification, user: @user, title: 'a' * 201
      refute notification.valid?
    end
  end

  describe 'scopes' do
    before do
      @unread = create :notification, user: @user, title: 'Unread'
      @read = create :notification, user: @user, title: 'Read', read_at: Time.current
    end

    it 'should return unread notifications' do
      assert_includes Notification.unread, @unread
      refute_includes Notification.unread, @read
    end

    it 'should return read notifications' do
      assert_includes Notification.read, @read
      refute_includes Notification.read, @unread
    end

    it 'should return recent notifications ordered by created_at desc' do
      recent = Notification.recent
      assert_equal @read, recent.first  # created second
    end

    it 'should limit for_dropdown to unread only' do
      dropdown = Notification.for_dropdown
      assert_includes dropdown, @unread
      refute_includes dropdown, @read
    end
  end

  describe 'read?' do
    it 'should return false when read_at is nil' do
      notification = build :notification, read_at: nil
      refute notification.read?
    end

    it 'should return true when read_at is set' do
      notification = build :notification, read_at: Time.current
      assert notification.read?
    end
  end

  describe 'mark_as_read!' do
    it 'should set read_at timestamp' do
      notification = create :notification, user: @user
      assert_nil notification.read_at

      notification.mark_as_read!
      assert_not_nil notification.reload.read_at
    end

    it 'should not update already-read notification' do
      original_time = 1.hour.ago
      notification = create :notification, user: @user, read_at: original_time

      notification.mark_as_read!
      assert_in_delta original_time, notification.reload.read_at, 1
    end
  end

  describe 'mark_all_read!' do
    it 'should mark all unread notifications as read' do
      create :notification, user: @user, title: 'N1'
      create :notification, user: @user, title: 'N2'
      create :notification, user: @user, title: 'N3', read_at: Time.current

      assert_equal 2, @user.notifications.unread.count
      Notification.mark_all_read!(@user)
      assert_equal 0, @user.notifications.unread.count
    end
  end

  describe 'notify!' do
    it 'should create notification with canonical kwargs' do
      notification = Notification.notify!(
        user: @user,
        title: 'Test',
        body: 'Body text',
        notification_type: 'follow_up',
        link: '/patients/1'
      )

      assert notification.persisted?
      assert_equal 'Test', notification.title
      assert_equal 'Body text', notification.body
      assert_equal 'follow_up', notification.notification_type
      assert_equal '/patients/1', notification.link
    end

    it 'should create notification with legacy kwargs (type: and related:)' do
      notification = Notification.notify!(
        user: @user,
        title: 'Legacy Test',
        type: 'handoff',
        related: '/patients/2'
      )

      assert notification.persisted?
      assert_equal 'handoff', notification.notification_type
      assert_equal '/patients/2', notification.link
    end

    it 'should default notification_type to info' do
      notification = Notification.notify!(
        user: @user,
        title: 'Default Type'
      )
      assert_equal 'info', notification.notification_type
    end

    it 'should require user and title' do
      assert_raises(ActiveRecord::RecordInvalid) do
        Notification.notify!(user: @user, title: nil)
      end
    end
  end

  describe 'tenant isolation' do
    it 'should scope notifications to current tenant' do
      notification = create :notification, user: @user
      assert_equal ActsAsTenant.current_tenant, notification.fund
    end
  end
end
