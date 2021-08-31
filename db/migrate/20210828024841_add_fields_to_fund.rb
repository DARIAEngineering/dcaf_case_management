class AddFieldsToFund < ActiveRecord::Migration[6.1]
  def change
    add_column :funds, :full_name, :string
    add_column :funds, :site_domain, :string
    add_column :funds, :phone, :string
    add_column :funds, :fax_service_url, :string
  end
end
