# Object representing a case manager dialing a patient.
class Call
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp
  include EventLoggable

  # Relationships
  embedded_in :patient

  # Fields
  field :status, type: String

  # Validations
  allowed_statuses = ['Reached patient',
                      'Left voicemail',
                      "Couldn't reach patient"]
  validates :status,  presence: true,
                      inclusion: { in: allowed_statuses }
  validates :created_by_id, presence: true

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'

  def recent?
    updated_at > 8.hours.ago ? true : false
  end

  def reached?
    status == 'Reached patient'
  end

  CALL_ARCHIVE_REFERENCE = {
    '_id'           => :keep,
    'status'        => :keep,
    'created_at'    => :keep,
    'created_by_id' => :keep,
    'updated_at'    => :keep,
    'version'       => :keep,
  }.freeze

  # still not DRY
  def archive!
    self.attributes.keys.each do |field|
      if CALL_ARCHIVE_REFERENCE.has_key?(field)
        action = CALL_ARCHIVE_REFERENCE[field]
        if action == :keep
          #puts "Found a keep! (#{field})"
          next
        elsif action == :shred
          #puts "Found a #{action} for field #{field}!"
          self[field] = nil
        else
          logger.warn "Func '#{action}' for call field '#{field}' not found. Shredding"
          #puts "Func '#{action}' for field '#{field}' not found. Shredding"
          self[field] = nil
        end
      else
        logger.warn "Found unaccounted for key '#{field}' on call when archiving. " \
                    "Shredding the content of this field. Please add proper " \
                    "handling for the field in the archive concern"
        self[field] = nil
      end
    end
    self.save
  end

  def event_params
    {
      event_type:   status,
      cm_name:      created_by&.name || 'System',
      patient_name: patient.name,
      patient_id:   patient.id,
      line:         patient.line
    }
  end

end
