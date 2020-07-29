class CreateExternalPledges < ActiveRecord::Migration[6.0]
  def change
    create_table :external_pledges do |t|
      t.string :source, null: false
      t.integer :amount
      t.boolean :active
      t.references :can_pledge, polymorphic: true, null: false

      t.timestamps
    end
  end
end
