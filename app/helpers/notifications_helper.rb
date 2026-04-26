module NotificationsHelper
  BADGE_CLASSES = {
    "info" => "info",
    "follow_up" => "warning",
    "stale_patient" => "secondary",
    "handoff" => "primary",
    "overdue_support" => "danger",
    "system" => "dark"
  }.freeze

  def notification_badge_class(notification_type)
    BADGE_CLASSES[notification_type] || "info"
  end
end
