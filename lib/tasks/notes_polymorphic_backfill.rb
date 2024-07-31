desc 'Backfill notes polymorphism data'
task notes_polymorphic_backfill: :environment do
  Note.where(can_note: nil).each do |note|
    note.can_note_id = note.patient_id
    note.can_note_type = 'Patient'
  end
end
