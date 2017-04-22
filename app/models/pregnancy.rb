# Object representing pregnancy outcomes and status of a patient.
class Pregnancy
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp
  include LastMenstrualPeriodHelper

  # Relationships
  embedded_in :patient

  # Fields
  # Intake information
  field :last_menstrual_period_weeks, type: Integer
  field :last_menstrual_period_days, type: Integer

  # General patient information
  field :special_circumstances, type: String # TODO change to a has_many through

  # Procedure result - generally for administrative use
  field :fax_received, type: Boolean
  field :procedure_cost, type: Integer
  field :procedure_date, type: DateTime
  field :procedure_completed_date, type: DateTime
  field :resolved_without_dcaf, type: Boolean
  field :referred_to_clinic, type: Boolean

  # Temp fields associated with pledges: TEMPORARY
  field :patient_contribution, type: Integer
  field :naf_pledge, type: Integer
  field :dcaf_soft_pledge, type: Integer
  field :pledge_sent, type: Boolean

  # Validations
  validates :created_by_id,
            presence: true
  validate :pledge_sent, :pledge_info_presence, if: :updating_pledge_sent?

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'

  # Methods - see also the helpers

  # def pledge_status?(status)
  #   pledges.each do |pledge|
  #     return true if pledge[status]
  #   end
  #   false
  # end

  def pledge_info_present?
    pledge_info_presence
    errors.messages.present?
  end

  def pledge_info_errors
    errors.messages.values.flatten.uniq
  end

  private

  def updating_pledge_sent?
    pledge_sent == true
  end

  def pledge_info_presence
    errors.add(:pledge_sent, 'DCAF soft pledge field cannot be blank') if dcaf_soft_pledge.blank?
    errors.add(:pledge_sent, 'Patient name cannot be blank') if patient.name.blank?
    errors.add(:pledge_sent, 'Clinic name cannot be blank') if patient.clinic.blank?
    errors.add(:pledge_sent, 'Appointment date cannot be blank') if patient.appointment_date.blank?
  end
end
