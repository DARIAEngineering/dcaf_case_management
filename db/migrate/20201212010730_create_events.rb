class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.string :cm_name
      t.integer :event_type
      t.string :line
      t.string :patient_name
      t.string :patient_id
      t.integer :pledge_amount

      t.timestamps
    end

    add_index :events, :created_at
    add_index :events, :line
  end
end
