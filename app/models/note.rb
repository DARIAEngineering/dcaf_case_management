# A case manager's log of their interactions with a patient.
# A patient embeds many notes.
class Note < MongoNote
  # Validations
  validates :created_by_id, :full_text, presence: true
end
