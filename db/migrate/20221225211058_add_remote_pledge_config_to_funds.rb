class AddRemotePledgeConfigToFunds < ActiveRecord::Migration[7.0]
  def change
    add_column :funds, :remote_pledge_config, :boolean, comment: 'Whether to use the remote pledge generation service'
  end
end
