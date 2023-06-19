class AddSupportDateToPracticalSupport < ActiveRecord::Migration[7.0]
  def change
    add_column :practical_supports, :support_date, :date
  end
end
