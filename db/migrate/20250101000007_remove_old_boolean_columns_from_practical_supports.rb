class RemoveOldBooleanColumnsFromPracticalSupports < ActiveRecord::Migration[8.1]
  # Contract phase: remove legacy boolean columns now replaced by the
  # :status enum added in 20250101000006_add_status_to_practical_supports.
  #
  # Deploy sequence:
  #   1. Deploy the expand migration (add status + backfill data).
  #   2. Deploy code that uses the new status enum (with ignored_columns).
  #   3. Once stable, deploy this contract migration to drop the old columns
  #      and remove ignored_columns from the model.
  def up
    remove_column :practical_supports, :confirmed
    remove_column :practical_supports, :fulfilled
  end

  def down
    add_column :practical_supports, :confirmed, :boolean
    add_column :practical_supports, :fulfilled, :boolean

    execute <<-SQL.squish
      UPDATE practical_supports SET confirmed = TRUE WHERE status = 2;
      UPDATE practical_supports SET fulfilled = TRUE WHERE status = 3;
    SQL
  end
end
