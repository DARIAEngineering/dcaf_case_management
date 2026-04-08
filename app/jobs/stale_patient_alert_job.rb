class StalePatientAlertJob < ApplicationJob
  queue_as :default

  def perform
    Fund.all.each do |fund|
      ActsAsTenant.with_tenant(fund) do
        days = Config.stale_patient_days
        stale_patients = Patient.stale(days)

        stale_patients.find_each do |patient|
          # Notify users who have this patient on their call list
          user_ids = CallListEntry.where(patient: patient).pluck(:user_id).uniq
          users = user_ids.any? ? User.where(id: user_ids) : User.where(role: [:admin])

          users.each do |user|
            # Skip if there's already an unread stale notification for this patient
            next if Notification.where(
              user: user,
              notification_type: :stale_patient,
              related_type: 'Patient',
              related_id: patient.id,
              read_at: nil
            ).exists?

            Notification.notify!(
              user: user,
              type: :stale_patient,
              title: "Stale patient: #{patient.name}",
              body: "No activity in #{days} days (last updated #{patient.updated_at.strftime('%b %d')})",
              related: patient
            )
          end
        end
      end
    end
  end
end
