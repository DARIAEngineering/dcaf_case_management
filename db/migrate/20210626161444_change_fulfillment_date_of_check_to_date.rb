class ChangeFulfillmentDateOfCheckToDate < ActiveRecord::Migration[6.1]
  def up
    change_column :fulfillments, :date_of_check, 'date USING date_of_check::date'
  end

  def down
    change_column :fulfillments, :date_of_check, :string
  end
end
