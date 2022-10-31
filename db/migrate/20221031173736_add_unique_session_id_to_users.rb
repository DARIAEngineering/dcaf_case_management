# Add unique_session_id to users to support devise-security :session_limitable module.
# See https://github.com/devise-security/devise-security#session-limitable
class AddUniqueSessionIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :unique_session_id, :string
  end
end
