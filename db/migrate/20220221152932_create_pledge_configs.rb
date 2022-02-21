class CreatePledgeConfigs < ActiveRecord::Migration[6.1]
  def change
    create_table :pledge_configs do |t|
      t.string :contact_email
      t.string :billing_email
      t.string :phone
      t.string :logo_url
      t.integer :logo_height
      t.integer :logo_width
      t.string :address1
      t.string :address2

      t.timestamps
    end
  end
end
