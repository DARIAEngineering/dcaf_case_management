class Patient
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Enum
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

  before_validation :clean_fields

  STATUSES = {
    no_contact: 'No Contact Made',
    needs_appt: 'Needs Appointment',
    fundraising: 'Fundraising',
    pledge_sent: 'Pledge Sent',
    pledge_paid: 'Pledge Paid',
    resolved: 'Resolved Without DCAF'
  }.freeze

  # Relationships
  has_and_belongs_to_many :users, inverse_of: :patients
  embeds_one :pregnancy
  embeds_one :clinic
  embeds_many :calls
  embeds_many :pledges
  embeds_many :notes

  # Enable mass posting in forms
  accepts_nested_attributes_for :pregnancy
  accepts_nested_attributes_for :clinic

  # Fields
  field :name, type: String # strip
  field :primary_phone, type: String
  field :other_contact, type: String
  field :other_phone, type: String
  field :other_contact_relationship, type: String

  enum :voicemail_preference, [:not_specified, :no, :yes]
  enum :line, [:DC, :MD, :VA]
  field :spanish, type: Boolean

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
  field :appointment_date, type: Date
  field :initial_call_date, type: Date

  field :urgent_flag, type: Boolean

  # Validations
  validates :name,
            :primary_phone,
            :initial_call_date,
            :created_by,
            presence: true
  validates :primary_phone, format: /\d{10}/, length: { is: 10 }
  validates :other_phone, format: /\d{10}/, length: { is: 10 }, allow_blank: true
  validates :appointment_date, format: /\A\d{4}-\d{1,2}-\d{1,2}\z/,
                               allow_blank: true

  validate :confirm_appointment_after_initial_call

  validates_associated :pregnancy

  # some validation of presence of at least one pregnancy
  # some validation of only one active pregnancy at a time

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'

  # Methods
  def status
    if pregnancy.resolved_without_dcaf?
      STATUSES[:resolved]
    # elsif pledge_status?(:paid)
    #   STATUSES[:pledge_paid]
    elsif pregnancy.pledge_sent?
      STATUSES[:pledge_sent]
    elsif appointment_date
      STATUSES[:fundraising]
    elsif contact_made?
      STATUSES[:needs_appt]
    else
      STATUSES[:no_contact]
    end
  end

  def self.urgent_pregnancies
    where(urgent_flag: true)
  end

  def self.trim_urgent_patients
    patient.each do |patient|
      unless patient.still_urgent?
        patient.urgent_flag = false
        patient.save
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

  def primary_phone_display
    return nil unless primary_phone.present?
    "#{primary_phone[0..2]}-#{primary_phone[3..5]}-#{primary_phone[6..9]}"
  end

  def other_phone_display
    return nil unless other_phone.present?
    "#{other_phone[0..2]}-#{other_phone[3..5]}-#{other_phone[6..9]}"
  end

  def identifier # unique ID made up by DCAF to easier identify patients
    return nil unless line
    "#{line[0]}#{primary_phone[-5]}-#{primary_phone[-4..-1]}"
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

  def confirm_appointment_after_initial_call
    if appointment_date.present? && initial_call_date > appointment_date
      errors.add(:appointment_date, 'must be after date of initial call')
    end
  end


  # Search-related stuff
  class << self
    # Case insensitive and phone number format agnostic!
    def search(name_or_phone_str)
      name_regexp = /#{Regexp.escape(name_or_phone_str)}/i
      clean_phone = name_or_phone_str.gsub(/\D/, '')
      phone_regexp = /#{Regexp.escape(clean_phone)}/

      all_matching_names = find_name_matches name_regexp
      all_matching_phones = find_phone_matches phone_regexp

      (all_matching_names | all_matching_phones)
    end

    private

    def find_name_matches(name_regexp)
      if nonempty_regexp? name_regexp
        primary_names = Patient.where name: name_regexp
        other_names = Patient.where other_contact: name_regexp
        return (primary_names | other_names)
      end
      []
    end

    def find_phone_matches(phone_regexp)
      if nonempty_regexp? phone_regexp
        primary_phones = Patient.where primary_phone: phone_regexp
        other_phones = Patient.where other_phone: phone_regexp
        return (primary_phones | other_phones)
      end
      []
    end

    def nonempty_regexp?(regexp)
      # Escaped regexes are always present, so check presence
      # after stripping out standard stuff
      # (opening stuff to semicolon, closing parenthesis)
      regexp.to_s.gsub(/^.*:/, '').chop.present?
    end
  end

  private

  def clean_fields
    primary_phone.gsub!(/\D/, '') if primary_phone
    other_phone.gsub!(/\D/, '') if other_phone
    name.strip! if name
    other_contact.strip! if other_contact
    other_contact_relationship.strip! if other_contact_relationship
  end
end
