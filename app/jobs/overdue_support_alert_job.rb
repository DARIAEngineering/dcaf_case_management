class OverdueSupportAlertJob < ApplicationJob
  queue_as :default

  def perform
    Fund.all.each do |fund|
      ActsAsTenant.with_tenant(fund) do
        PracticalSupport.overdue.includes(:can_support).find_each do |support|
          patient = support.can_support
          next unless patient.is_a?(Patient)

          # Notify admins about overdue practical support
          User.where(role: :admin).find_each do |admin|
            support_link = "/patients/#{patient.id}/edit"

            next if Notification.where(
              user: admin,
              notification_type: "overdue_support",
              link: support_link,
              read_at: nil
            ).exists?

            Notification.notify!(
              user: admin,
              notification_type: "overdue_support",
              title: "Overdue support: #{support.support_type}",
              body: "#{support.support_type} for #{patient.name} has been #{support.status} for #{((Time.current - support.created_at) / 1.day).round} days",
              link: support_link
            )
          end
        end
      end
    end
  end
end
