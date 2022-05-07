class ChangePracticalSupportAmountToDecimal < ActiveRecord::Migration[6.1]
    def change
      rename_column :patients, :urgent_flag, :flagged
    end
  end
  