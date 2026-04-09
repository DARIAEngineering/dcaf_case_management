require 'test_helper'

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  include IntegrationHelper

  before do
    @user = create :user
    @line = create :line
    sign_in @user
    choose_line @line
  end

  describe 'index' do
    it 'should return success' do
      get notifications_path
      assert_response :success
    end

    it 'should show only current user notifications' do
      my_notification = create :notification, user: @user, title: 'Mine'
      other_user = create :user
      other_notification = create :notification, user: other_user, title: 'Not Mine'

      get notifications_path
      assert_response :success
      assert_match 'Mine', response.body
      refute_match 'Not Mine', response.body
    end
  end

  describe 'mark_read' do
    it 'should mark a notification as read' do
      notification = create :notification, user: @user
      assert_nil notification.read_at

      patch mark_read_notification_path(notification)
      assert_response :ok
      assert_not_nil notification.reload.read_at
    end

    it 'should not allow marking another user notification' do
      other_user = create :user
      notification = create :notification, user: other_user

      assert_raises(ActiveRecord::RecordNotFound) do
        patch mark_read_notification_path(notification)
      end
    end
  end

  describe 'mark_all_read' do
    it 'should mark all unread notifications as read' do
      create :notification, user: @user, title: 'N1'
      create :notification, user: @user, title: 'N2'

      assert_equal 2, @user.notifications.unread.count
      patch mark_all_read_notifications_path
      assert_response :redirect
      assert_equal 0, @user.notifications.unread.count
    end
  end

  describe 'authentication' do
    it 'should require authentication' do
      delete destroy_user_session_path
      get notifications_path
      assert_response :redirect
    end
  end
end
