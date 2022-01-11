class ChangePracticalSupportAmountToDecimal < ActiveRecord::Migration[6.1]
  def change
    change_column :practical_supports, :amount, :decimal, precision: 8, scale: 2 
  end
end
