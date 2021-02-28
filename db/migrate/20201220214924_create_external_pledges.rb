class CreateExternalPledges < ActiveRecord::Migration[6.0]
  def change
    create_table :external_pledges do |t|
      t.string :source, null: false
      t.integer :amount
      t.boolean :active 

      t.references :can_pledge, polymorphic: true, null: false

      # Scratch field - temporary BSON ID from Mongo so we can link things back
      t.string :mongo_id

      t.timestamps
    end
  end
end
