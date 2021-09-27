class AllowMultitenantValidation < ActiveRecord::Migration[6.1]
  def change
    # This rescopes uniqueness on a few models to be within a particular fund_id.
    # For ex, a user can have an account with more than one fund.
    remove_index :users, :email, unique: true
    add_index :users, [:email, :fund_id], unique: true

    # And a patient might show up in multiple funds.
    remove_index :patients, :primary_phone, unique: true
    add_index :patients, [:primary_phone, :fund_id], unique: true

    # And every fund has their own set of configs.
    remove_index :configs, :config_key, unique: true
    add_index :configs, [:config_key, :fund_id], unique: true
  end
end
