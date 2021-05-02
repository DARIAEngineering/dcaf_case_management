# Object representing a case manager dialing a patient.
class MongoCall
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp
  include EventLoggable

  # Relationships
  embedded_in :can_call, polymorphic: true

  # Fields
  field :status, type: String

  # Validations
  ALLOWED_STATUSES = {
    'Reached patient' => :reached_patient,
    'Left voicemail' => :left_voicemail,
    "Couldn't reach patient" => :couldnt_reach_patient
  }
  validates :status,  presence: true,
                      inclusion: { in: ALLOWED_STATUSES.keys }
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
      event_type:   ALLOWED_STATUSES[status],
      cm_name:      created_by&.name || 'System',
      patient_name: can_call.name,
      patient_id:   can_call.id,
      line:         can_call.line
    }
  end
end
