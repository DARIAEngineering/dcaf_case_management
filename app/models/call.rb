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
  validates :status, presence: true

  # Methods
  def recent?
    updated_at > 8.hours.ago ? true : false
  end

  def event_params
    user = User.find_by(id: PaperTrail&.request&.whodunnit)
    {
      event_type:   status.to_s,
      cm_name:      user&.name || 'System',
      patient_name: can_call.name,
      patient_id:   can_call.id,
      line:         can_call.line
    }
  end
end
