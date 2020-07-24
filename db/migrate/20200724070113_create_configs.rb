class CreateConfigs < ActiveRecord::Migration[6.0]
  def change
    create_table :configs do |t|
      t.integer :config_key, null: false
      t.hstore :config_value, default: { options: [] }, null: false

      t.timestamps
    end
    add_index :configs, :config_key
  end
end
