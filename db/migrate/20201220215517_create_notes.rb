class CreateNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :notes do |t|
      t.string :full_text, null: false

      t.references :patient

      t.timestamps
    end
  end
end
