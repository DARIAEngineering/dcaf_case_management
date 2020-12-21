# Object representing a case manager dialing a patient.
class Call < ApplicationRecord
  # Concerns
  include EventLoggable
  include PaperTrailable

  # Enums
  enum status: {
    reached_patient: 0,
    left_voicemail: 1,
    couldnt_reach_patient: 2
  }

  # Relationships
  belongs_to :can_call, polymorphic: true

  # Validations
  validates :status, presence: true,
                    inclusion: { in: ALLOWED_STATUSES.keys }

  # Methods
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
