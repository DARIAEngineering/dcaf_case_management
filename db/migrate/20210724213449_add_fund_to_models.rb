class AddFundToModels < ActiveRecord::Migration[6.1]
  def change
    %w(archived_patients clinics patients users configs events call_list_entries).each do |model|
      add_reference model, :fund, foreign_key: true
    end
  end
end
