# Object representing a case manager dialing a patient.
class Call
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp
  include EventLoggable

  # Relationships
  embedded_in :callable, polymorphic: true

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

  def event_params
    {
      event_type:   status,
      cm_name:      created_by&.name || 'System',
      #patient_name: patient.name,
      #patient_id:   patient.id,
      line:         callable.line
    }
  end
end
