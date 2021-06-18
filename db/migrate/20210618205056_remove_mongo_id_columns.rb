class RemoveMongoIdColumns < ActiveRecord::Migration[6.0]
  def change
    %w(archived_patients clinics patients users).each do |model|
      remove_column model, :mongo_id, :string
    end
  end
end
