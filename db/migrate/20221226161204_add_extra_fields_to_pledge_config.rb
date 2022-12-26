class AddExtraFieldsToPledgeConfig < ActiveRecord::Migration[7.0]
  def change
    add_column :pledge_configs, :remote_pledge, :boolean, comment: 'Whether to use the remote pledge generation service'
    add_column :pledge_configs, :remote_pledge_extras, :json, comment: 'Extra fields required for remote pledge generation'
  end
end
