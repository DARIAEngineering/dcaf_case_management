class CreateCalls < ActiveRecord::Migration[6.0]
  def change
    create_table :calls do |t|
      t.string :status
      t.references :can_call, polymporphic: true

      t.timestamps
    end
  end
end
