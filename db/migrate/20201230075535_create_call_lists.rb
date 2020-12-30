class CreateCallLists < ActiveRecord::Migration[6.0]
  def change
    create_table :call_lists do |t|
      t.references :user, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: true

      t.integer :order_key, null: false

      t.timestamps
    end
  end
end
