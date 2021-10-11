class AddFieldsToFund < ActiveRecord::Migration[6.1]
  def change
    add_column :funds, :full_name, :string, comment: 'Full name of the fund. e.g. DC Abortion Fund'
    add_column :funds, :site_domain, :string, comment: "URL of the fund's public-facing website. e.g. www.dcabortionfund.org"
    add_column :funds, :phone, :string, comment: 'Contact number for the abortion fund, usually the hotline'
  end
end
