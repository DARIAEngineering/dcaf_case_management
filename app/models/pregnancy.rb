class Pregnancy
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp
  include LastMenstrualPeriodHelper

  # Relationships
  belongs_to :patient
  has_and_belongs_to_many :users, inverse_of: :pregnancies
  embeds_many :pledges
  embeds_many :notes
  embeds_many :calls
  has_one :clinic

  # Enable mass posting in forms
  accepts_nested_attributes_for :patient
  accepts_nested_attributes_for :clinic

  # Fields
  # Intake information
  field :initial_call_date, type: Date
  field :last_menstrual_period_weeks, type: Integer
  field :last_menstrual_period_days, type: Integer
  field :voicemail_ok, type: Boolean, default: false
  field :line, type: String # DC, MD, VA
  field :language, type: String
  field :appointment_date, type: Date
  field :urgent_flag, type: Boolean

  # General patient information
  field :age, type: Integer
  field :city, type: String
  field :state, type: String # ennumeration?
  field :zip, type: String
  field :county, type: String
  field :race_ethnicity, type: String
  field :employment_status, type: String
  field :household_size, type: Integer
  field :insurance, type: String
  field :income, type: String
  field :referred_by, type: String
  field :special_circumstances, type: String # ennumeration

  # Procedure result - generally for administrative use
  field :fax_received, type: Boolean
  field :procedure_cost, type: Integer
  field :procedure_date, type: DateTime
  field :procedure_completed_date, type: DateTime
  field :resolved_without_dcaf, type: Boolean

  # Temp fields associated with pledges: TEMPORARY
  field :patient_contribution, type: Integer
  field :naf_pledge, type: Integer
  field :dcaf_soft_pledge, type: Integer
  field :pledge_sent, type: Boolean

  # Validations
  validates :initial_call_date,
            :created_by,
            presence: true
  validates :appointment_date, format: /\A\d{4}-\d{1,2}-\d{1,2}\z/,
                               allow_blank: true
  validate :confirm_appointment_after_initial_call
  validates_associated :patient

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'

  # Methods - see also the helpers
  def self.most_recent
    order('created_at DESC').limit(1).first
  end

  def recent_calls
    calls.order('created_at DESC').limit(10)
  end

  def old_calls
    calls.order('created_at DESC').offset(10)
  end

  def most_recent_note_display_text
    display_note = most_recent_note[0..40]
    display_note << '...' if most_recent_note.length > 41
    display_note
  end

  def most_recent_note
    notes.order('created_at DESC').limit(1).first.try(:full_text).to_s
  end

  def pledge_identifier # unique ID made up by DCAF to easier identify patients
    return nil unless line
    "#{line[0]}#{patient.primary_phone[-5]}-#{patient.primary_phone[-4..-1]}"
  end

  def status
    if resolved_without_dcaf?
      'Resolved Without DCAF'
    # elsif pledge_status?(:paid)
    #   status = "Pledge Paid"
    elsif pledge_sent?
      'Pledge sent'
    elsif appointment_date
      'Fundraising'
    elsif contact_made?
      'Needs Appointment'
    else
      'No Contact Made'
    end
  end

  def confirm_appointment_after_initial_call
    if appointment_date.present? && initial_call_date > appointment_date
      errors.add(:appointment_date, 'must be after date of initial call')
    end
  end

  private

  def contact_made?
    calls.each do |call|
      return true if call.status == 'Reached patient'
    end
    false
  end

  # def pledge_status?(status)
  #   pledges.each do |pledge|
  #     return true if pledge[status]
  #   end
  #   false
  # end
end
