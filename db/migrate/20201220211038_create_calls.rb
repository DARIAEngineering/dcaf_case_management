class CreateCalls < ActiveRecord::Migration[6.0]
  def change
    create_table :calls do |t|
      t.integer :status, null: false

      t.references :can_call, polymorphic: true, null: false

      # Scratch field - temporary BSON ID from Mongo so we can link things back
      t.string :mongo_id

      t.timestamps
    end
  end
end
