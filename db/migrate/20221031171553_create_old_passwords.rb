# Creates old_passwords table to support devise-security's :password_archivable module.
# See https://github.com/devise-security/devise-security#password-archivable
class CreateOldPasswords < ActiveRecord::Migration[7.0]
  def change
    create_table :old_passwords do |t|
      t.string :encrypted_password, null: false
      t.string :password_archivable_type, null: false
      t.integer :password_archivable_id, null: false
      t.string :password_salt
      t.datetime :created_at
    end
    add_index :old_passwords, [:password_archivable_type, :password_archivable_id], name: 'index_password_archivable'
  end
end
