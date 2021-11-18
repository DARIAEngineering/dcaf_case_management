class AddAmountsToPracticalSupport < ActiveRecord::Migration[6.1]
  def change
    add_column :practical_supports, :amount, :integer
  end
end
