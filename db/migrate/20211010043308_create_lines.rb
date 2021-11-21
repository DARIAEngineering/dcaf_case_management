class CreateLines < ActiveRecord::Migration[6.1]
  def change
    create_table :lines do |t|
      t.string :name, null: false
      t.references :fund, null: false, foreign_key: true

      t.timestamps
    end
  end
end
