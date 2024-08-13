class AddPurchaseDateToPracticalSupport < ActiveRecord::Migration[7.1]
  def change
    add_column :practical_supports, :purchase_date, :date, comment: 'Date of purchase, if applicable'
  end
end
