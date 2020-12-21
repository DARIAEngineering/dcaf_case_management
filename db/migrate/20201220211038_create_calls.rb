class CreateCalls < ActiveRecord::Migration[6.0]
  def change
    create_table :calls do |t|
      t.integer :status, null: false

      t.references :can_call, polymorphic: true, null: false

      t.timestamps
    end
  end
end
