class AddSessionValidityTokenToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :session_validity_token, :string
  end
end
