# A case manager's log of their interactions with a patient.
# A patient embeds many notes.
class Note
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

  # Relationships
  embedded_in :patient

  # Fields
  field :full_text, type: String

  # Validations
  validates :created_by_id, :full_text, presence: true

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'

  NOTE_ARCHIVE_REFERENCE = {
    'full_text'     => :shred,
    '_id'           => :keep,
    'created_at'    => :keep,
    'created_by_id' => :keep,
    'updated_at'    => :keep,
    'version'       => :keep,
  }.freeze


  # still not DRY
  def archive!
    self.attributes.keys.each do |field|
      if NOTE_ARCHIVE_REFERENCE.has_key?(field)
        action = NOTE_ARCHIVE_REFERENCE[field]
        if action == :keep
          #puts "Found a keep! (#{field})"
          next
        elsif action == :shred
          #puts "Found a #{action} for field #{field}!"
          self[field] = nil
        else
          logger.warn "Func '#{action}' for note field '#{field}' not found. Shredding"
          #puts "Func '#{action}' for field '#{field}' not found. Shredding"
          self[field] = nil
        end
      else
        logger.warn "Found unaccounted for key '#{field}' on Note when archiving. " \
                    "Shredding the content of this field. Please add proper " \
                    "handling for the field in the archive concern"
        self[field] = nil
      end
    end
    self.save
  end
end
