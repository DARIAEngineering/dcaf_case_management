class AddWaiverAndPurchaseDateToPracticalSupport < ActiveRecord::Migration[7.1]
  def change
    add_column :practical_supports, :waiver, :boolean, comment: 'An indicator of whether a patient has signed a waiver or other release paperwork'
    add_column :practical_supports, :purchase_date, :date, comment: 'Date of purchase of services'
  end
end
