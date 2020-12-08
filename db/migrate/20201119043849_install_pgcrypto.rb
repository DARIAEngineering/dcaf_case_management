# This migration sets up pgcrypto, which lets us use uuids.
class InstallPgcrypto < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'pgcrypto'
  end
end
