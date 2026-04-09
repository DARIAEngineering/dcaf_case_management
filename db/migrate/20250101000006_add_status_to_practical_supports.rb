class AddStatusToPracticalSupports < ActiveRecord::Migration[8.1]
  def up
    # Expand: add status column alongside old boolean columns
    add_column :practical_supports, :status, :integer, default: 0, null: false
    add_column :practical_supports, :status_updated_at, :datetime

    # Migrate data from old boolean columns to new enum status:
    #   confirmed: true  → approved (2)
    #   fulfilled: true  → completed (3)
    #   otherwise        → requested (0, the default)
    execute <<-SQL.squish
      UPDATE practical_supports SET status = 3, status_updated_at = updated_at
        WHERE fulfilled = TRUE;
      UPDATE practical_supports SET status = 2, status_updated_at = updated_at
        WHERE confirmed = TRUE AND (fulfilled IS NULL OR fulfilled = FALSE);
    SQL

    # Contract: remove old boolean columns that are now replaced by the enum
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

    remove_column :practical_supports, :status
    remove_column :practical_supports, :status_updated_at
  end
end
