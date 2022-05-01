class RemovePledgeGenerationConfigFromFund < ActiveRecord::Migration[6.1]
  def change
    remove_column :funds, :pledge_generation_config
  end
end
