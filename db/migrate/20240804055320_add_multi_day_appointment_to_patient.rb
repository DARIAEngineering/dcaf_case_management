class AddMultiDayAppointmentToPatient < ActiveRecord::Migration[7.1]
  def change
    add_column :patients, :multiday_appointment, :boolean
    add_column :archived_patients, :multiday_appointment, :boolean
  end
end
