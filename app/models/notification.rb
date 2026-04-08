# In-app notification for case managers.
# Supports types: info, follow_up, stale_patient, handoff, overdue_support
class Notification < ApplicationRecord
  acts_as_tenant :fund

  # Relationships
  belongs_to :user

  # Validations
  validates :title, presence: true, length: { maximum: 200 }
  validates :body, length: { maximum: 1000 }
  validates :notification_type, presence: true,
            inclusion: { in: %w[info follow_up stale_patient handoff overdue_support system] }

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc).limit(50) }
  scope :for_dropdown, -> { unread.order(created_at: :desc).limit(10) }

  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end

  # Mark all unread notifications for a user as read
  def self.mark_all_read!(user)
    where(user: user).unread.update_all(read_at: Time.current)
  end

  # Create and broadcast a notification via Solid Cable
  def self.notify!(user:, title:, body: nil, notification_type: "info", link: nil)
    notification = create!(
      user: user,
      title: title,
      body: body,
      notification_type: notification_type,
      link: link
    )

    # Broadcast to user's notification channel for real-time updates
    ActionCable.server.broadcast(
      "notifications_#{user.id}",
      {
        id: notification.id,
        title: notification.title,
        body: notification.body,
        type: notification.notification_type,
        link: notification.link,
        created_at: notification.created_at.iso8601,
        unread_count: user.notifications.unread.count
      }
    )

    notification
  end
end
