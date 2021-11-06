class PortLines < ActiveRecord::Migration[6.1]
  def up
    [:archived_patients, :call_list_entries, :events, :patients].each do |tbl|
      rename_column tbl, :line, :line_legacy
      add_reference tbl, :line, foreign_key: true

      # Populate the new column with Line object refs
      model = tbl.to_s.classify.constantize
      all_lines = model.distinct
                       .pluck(:line_legacy, :fund_id)
                       .map { |x| Line.find_or_create_by name: x[0], fund_id: x[1] }

      all_lines.each do |line|
        model.where(line_legacy: line.name, fund_id: line.fund_id)
             .update_all(line_id: line.id)
      end

      change_column_null tbl, :line_id, false
      change_column_null tbl, :line_legacy, true
    end
  end

  def down
    [:archived_patients, :call_list_entries, :events, :patients].each do |tbl|
      add_column tbl, :line_legacy, :string

      model = tbl.to_s.classify.constantize

      Line.all.each do |line|
        model.where(line_id: line.id, fund_id: line.fund_id)
             .update_all(line_legacy: line.name)
      end

      remove_reference tbl, :line
      rename_column tbl, :line_legacy, :line
      change_column_null tbl, :line, false
    end
  end
end
