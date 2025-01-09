class AddAppointmentTimeToPatient < ActiveRecord::Migration[7.1]
  def change
    add_column :patients, :appointment_time, :time, comment: "A patient's appointment time"
  end
end
