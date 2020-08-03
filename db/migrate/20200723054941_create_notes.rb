class CreateNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :notes do |t|
      t.text :full_text
      t.references :patient, null: false, foreign_key: true

      t.timestamps
    end
  end
end
