class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :line
      t.boolean :disabled_by_fund
      t.string :call_order, array: true
      t.integer :role, default: 0

      t.timestamps
    end
  end
end
