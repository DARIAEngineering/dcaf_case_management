class AddFieldsToPracticalSupport < ActiveRecord::Migration[7.1]
  def change
    add_column :practical_supports, :attachment_url, :string, comment: "A link to a fund's stored receipt for this particular entry"
    add_column :practical_supports, :fulfilled, :string, comment: 'An indicator that a particular practical support is fulfilled, completed, or paid out.'
  end
end
