class ChangeFulfillmentDateOfCheckToDate < ActiveRecord::Migration[6.1]
  def up
    change_column :fulfillments,
                  :date_of_check,
                  "date USING case when date_of_check = '' then null else date_of_check::date end"
  end

  def down
    change_column :fulfillments, :date_of_check, :string
  end
end
