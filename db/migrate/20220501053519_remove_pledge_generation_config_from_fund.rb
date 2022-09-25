class RemovePledgeGenerationConfigFromFund < ActiveRecord::Migration[6.1]
  def change
    remove_column :funds, :pledge_generation_config, :string, comment: 'Optional config of which pledge generation configset to use. If null, pledge generation is shut off'
  end
end
