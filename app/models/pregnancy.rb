class Pregnancy
  include Mongoid::Document
  include Mongoid::Enum
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp
  include LastMenstrualPeriodHelper

  STATUSES = {
    no_contact: 'No Contact Made',
    needs_appt: 'Needs Appointment',
    fundraising: 'Fundraising',
    pledge_sent: 'Pledge Sent',
    pledge_paid: 'Pledge Paid',
    resolved: 'Resolved Without DCAF'
  }

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
  enum :voicemail_preference, [:not_specified, :no, :yes]
  enum :line, [:DC, :MD, :VA]
  field :spanish, type: Boolean
  field :appointment_date, type: Date
  field :urgent_flag, type: Boolean

  # General patient information
  field :age, type: Integer
  field :city, type: String
  field :state, type: String
  field :zip, type: String
  field :county, type: String
  field :race_ethnicity, type: String
  field :employment_status, type: String
  field :household_size_children, type: Integer
  field :household_size_adults, type: Integer
  field :insurance, type: String
  field :income, type: String
  field :referred_by, type: String
  field :special_circumstances, type: Array, default: []

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

  def self.urgent_pregnancies
    where(urgent_flag: true)
  end

  def self.trim_urgent_pregnancies
    urgent_pregnancies.each do |pregnancy|
      unless pregnancy.still_urgent?
        pregnancy.urgent_flag = false
        pregnancy.save
      end
    end
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
      STATUSES[:resolved]
    # elsif pledge_status?(:paid)
    #   STATUSES[:pledge_paid]
    elsif pledge_sent?
      STATUSES[:pledge_sent]
    elsif appointment_date
      STATUSES[:fundraising]
    elsif contact_made?
      STATUSES[:needs_appt]
    else
      STATUSES[:no_contact]
    end
  end

  def confirm_appointment_after_initial_call
    if appointment_date.present? && initial_call_date > appointment_date
      errors.add(:appointment_date, 'must be after date of initial call')
    end
  end

  def still_urgent?
    # Verify that a pregnancy has not been marked urgent in the past six days
    return false if recent_history_tracks.count == 0
    recent_history_tracks.sort.reverse.each do |history|
      return true if history.marked_urgent?
    end
    false
  end

  private

  def contact_made?
    calls.each do |call|
      return true if call.status == 'Reached patient'
    end
    false
  end

  def recent_history_tracks
    history_tracks.select { |ht| ht.updated_at > 6.days.ago }
  end

  # def pledge_status?(status)
  #   pledges.each do |pledge|
  #     return true if pledge[status]
  #   end
  #   false
  # end
end
