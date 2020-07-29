class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :line
      t.boolean :disabled_by_fund
      t.string :call_order, array: true
      t.integer :role, default: 0, null: false

      t.timestamps
    end

    add_index :users, :name
  end
end
