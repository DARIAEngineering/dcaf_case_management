class AddLineRelationToModels < ActiveRecord::Migration[6.1]
  def change
    %w(archived_patients patients events call_list_entries).each do |model|
      remove_column model, :line
      add_reference model, :line, foreign_key: true
    end
  end
end
