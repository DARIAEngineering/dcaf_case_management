class MakeNotesPolymorphic < ActiveRecord::Migration[7.1]
  def change
    add_reference :notes, :can_note, polymorphic: true, null: true
  end
end
