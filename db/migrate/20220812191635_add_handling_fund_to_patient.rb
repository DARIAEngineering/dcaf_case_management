class AddHandlingFundToPatient < ActiveRecord::Migration[7.0]
  def change
    add_column :patients, :handling_fund, :string
    add_column :archived_patients, :handling_fund, :string
  end
end
