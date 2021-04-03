class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :line
      t.integer :role, null: false, default: 0
      t.boolean :disabled_by_fund, default: false

      # Scratch field - temporary BSON ID from Mongo so we can link things back
      t.string :mongo_id

      t.timestamps
    end
  end
end
