class EnableHstoreExtension < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'hstore'
  end
end
