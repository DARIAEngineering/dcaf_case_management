class AddIndexToConfigKey < ActiveRecord::Migration[6.1]
  def change
    remove_index :configs, :config_key
    add_index :configs, :config_key, unique: true
  end
end
