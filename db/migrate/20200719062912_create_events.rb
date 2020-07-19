class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.string :cm_name
      t.integer :event_type
      t.integer :line
      t.string :patient_name
      t.string :patient_id
      t.integer :pledge_amount

      t.timestamps
    end
  end
end
