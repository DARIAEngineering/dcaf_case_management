# Object representing a case manager dialing a patient.
class Call < ApplicationRecord
  has_paper_trail
  include EventLoggable
  include HistoryTrackable

  # Relationships
  belongs_to :can_call, polymorphic: true

  # Validations
  # TODO make status an enum
  allowed_statuses = ['Reached patient',
                      'Left voicemail',
                      "Couldn't reach patient"]
  validates :status,  presence: true,
                      inclusion: { in: allowed_statuses }

  def recent?
    updated_at > 8.hours.ago ? true : false
  end

  def reached?
    status == 'Reached patient'
  end

  def event_params
    {
      event_type:   status,
      cm_name:      'System', # created_by&.name || 'System',
      patient_name: can_call.name,
      patient_id:   can_call.id,
      line:         can_call.line
    }
  end 
end
