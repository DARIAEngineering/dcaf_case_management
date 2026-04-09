class EncryptPatientPii < ActiveRecord::Migration[8.1]
  def change
    # Remove indexes on columns that are now encrypted with non-deterministic
    # encryption. These indexes are meaningless on encrypted data since the
    # ciphertext is different each time.
    #
    # Patient search now happens in-memory after decryption, so SQL indexes
    # on these columns provide no benefit.
    remove_index :patients, :name, if_exists: true
    remove_index :patients, :other_contact, if_exists: true
    remove_index :patients, :other_phone, if_exists: true

    # NOTE: We intentionally KEEP the unique index on
    # [:primary_phone, :fund_id] because primary_phone uses deterministic
    # encryption, which preserves index functionality.
  end
end
