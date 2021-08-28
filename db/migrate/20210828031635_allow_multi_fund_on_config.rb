class AllowMultiFundOnConfig < ActiveRecord::Migration[6.1]
  def change
    remove_index :configs, :config_key, unique: true
    add_index :configs, [:config_key, :fund_id], unique: true
  end
end
