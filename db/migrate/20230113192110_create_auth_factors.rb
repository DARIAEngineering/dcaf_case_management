class CreateAuthFactors < ActiveRecord::Migration[7.0]
  def change
    create_table :auth_factors do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :channel
      t.boolean :enabled, default: false
      t.boolean :registration_complete, default: false
      t.string :external_id
      t.string :phone
      t.string :email

      t.timestamps
    end
    add_index :auth_factors, %i[name user_id], unique: true
  end
end
