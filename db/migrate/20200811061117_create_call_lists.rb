class CreateCallLists < ActiveRecord::Migration[6.0]
  def change
    create_table :call_lists do |t|
      t.references :patient
      t.references :user

      t.timestamps
    end
  end
end
