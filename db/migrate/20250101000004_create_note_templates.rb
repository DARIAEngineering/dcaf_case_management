class CreateNoteTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :note_templates do |t|
      t.references :fund, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.string :name, null: false
      t.text :full_text, null: false
      t.timestamps
    end

    add_index :note_templates, [:fund_id, :user_id, :name], unique: true
  end
end
