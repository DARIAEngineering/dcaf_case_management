class CreateFunds < ActiveRecord::Migration[6.1]
  def change
    create_table :funds do |t|
      t.string :name
      t.string :subdomain
      t.string :domain

      t.timestamps
    end
  end
end
