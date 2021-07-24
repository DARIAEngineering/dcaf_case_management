class AllowMultiEmailOnUser < ActiveRecord::Migration[6.1]
  def change
    remove_index :users, :email, unique: true
    add_index :users, [:email, :fund_id], unique: true
  end
end
