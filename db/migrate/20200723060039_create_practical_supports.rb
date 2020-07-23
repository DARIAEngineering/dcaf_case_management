class CreatePracticalSupports < ActiveRecord::Migration[6.0]
  def change
    create_table :practical_supports do |t|
      t.string :support_type
      t.boolean :confirmed
      t.string :source
      t.references :can_support, polymorphic: true, null: false

      t.timestamps
    end
  end
end
