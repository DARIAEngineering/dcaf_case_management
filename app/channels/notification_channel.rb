# Channel for real-time notification delivery via Solid Cable
class NotificationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notifications_#{current_user.id}"
  end

  def unsubscribed
    # Cleanup when channel is disconnected
  end
end
