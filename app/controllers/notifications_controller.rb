class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.recent
  end

  def mark_read
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_read!
    head :ok
  end

  def mark_all_read
    Notification.mark_all_read!(current_user)
    redirect_to notifications_path, notice: I18n.t('notifications.all_marked_read')
  end
end
