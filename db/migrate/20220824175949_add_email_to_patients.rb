class AddEmailToPatients < ActiveRecord::Migration[7.0]
  def change
    add_column :patients, :email, :string
  end
end
