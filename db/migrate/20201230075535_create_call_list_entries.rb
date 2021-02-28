class CreateCallListEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :call_list_entries do |t|
      t.references :user, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: true

      t.string :line, null: false
      t.integer :order_key, null: false

      # Scratch field - temporary BSON ID from Mongo so we can link things back
      t.string :mongo_id

      t.timestamps
    end

    add_index :call_list_entries, :line
  end
end
