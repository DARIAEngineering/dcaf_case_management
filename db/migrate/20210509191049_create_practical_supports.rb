class CreatePracticalSupports < ActiveRecord::Migration[6.0]
  def change
    create_table :practical_supports do |t|
      t.string :support_type, null: false
      t.boolean :confirmed
      t.string :source, null: false

      t.references :can_support, polymorphic: true

      t.timestamps
    end
  end
end
