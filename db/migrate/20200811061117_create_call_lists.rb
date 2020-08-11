class CreateCallLists < ActiveRecord::Migration[6.0]
  def change
    create_table :call_lists do |t|
      t.patient :references
      t.user :references

      t.timestamps
    end
  end
end
