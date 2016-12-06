# Object representing core patient information and demographic data.
class Patient
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Enum
  include Mongoid::History::Trackable
  include Mongoid::Userstamp
  include StatusHelper

  LINES.each do |line|
    scope line.downcase.to_sym, -> { where(:_line.in => [line]) }
  end

  before_validation :clean_fields

  # Relationships
  has_and_belongs_to_many :users, inverse_of: :patients
  embeds_one :pregnancy
  embeds_one :fulfillment
  embeds_one :clinic
  embeds_many :calls
  embeds_many :external_pledges
  embeds_many :notes

  # Enable mass posting in forms
  accepts_nested_attributes_for :pregnancy
  accepts_nested_attributes_for :fulfillment
  accepts_nested_attributes_for :clinic

  # Fields
  field :name, type: String # strip
  field :primary_phone, type: String
  field :other_contact, type: String
  field :other_phone, type: String
  field :other_contact_relationship, type: String
  field :clinic_name, type: String

  enum :voicemail_preference, [:not_specified, :no, :yes]
  enum :line, [:DC, :MD, :VA] # See config/initializers/lines.rb. TODO: Env var.
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
  field :special_circumstances, type: Array, default: []

  # Indices
  index({ primary_phone: 1 }, unique: true)
  index(other_contact_phone: 1)
  index(name: 1)
  index(other_contact: 1)
  index(urgent_flag: 1)

  # Validations
  validates :name,
            :primary_phone,
            :initial_call_date,
            :created_by,
            :line,
            presence: true
  validates :primary_phone, format: /\d{10}/, length: { is: 10 }, uniqueness: true
  validates :other_phone, format: /\d{10}/,
                          length: { is: 10 },
                          allow_blank: true
  validates :appointment_date, format: /\A\d{4}-\d{1,2}-\d{1,2}\z/,
                               allow_blank: true

  validate :confirm_appointment_after_initial_call

  validates_associated :pregnancy
  validates_associated :fulfillment

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
  def self.urgent_patients(lines = LINES)
    Patient.in(_line: lines).where(urgent_flag: true)
  end

  def self.trim_urgent_patients
    Patient.all do |patient|
      unless patient.still_urgent?
        patient.urgent_flag = false
        patient.save
      end
    end
  end

  def self.pledged_status_summary(num_days = 7)
    # return pledge totals for patients with appts in the next num_days
    # TODO move to Pledge class, when implemented?
    outstanding_pledges = 0
    sent_total = 0
    Patient.where(:appointment_date.lte => Date.today + num_days).each do |patient|
      if patient.pregnancy.pledge_sent
        sent_total += (patient.pregnancy.dcaf_soft_pledge || 0)
      else
        outstanding_pledges += (patient.pregnancy.dcaf_soft_pledge || 0)
      end
    end
    { pledged: outstanding_pledges, sent: sent_total }
  end

  def recent_calls
    calls.order('created_at DESC').limit(10)
  end

  def old_calls
    calls.order('created_at DESC').offset(10)
  end

  def most_recent_note_display_text
    note_text = most_recent_note.try(:full_text).to_s
    display_note = note_text[0..40]
    display_note << '...' if note_text.length > 41
    display_note
  end

  def most_recent_note
    notes.order('created_at DESC').limit(1).first
  end

  # TODO: reimplement once pledge is available
  #def most_recent_pledge_display_date
  #  display_date = most_recent_pledge.try(:sent).to_s
  #  display_date
  #end

  # TODO: reimplement once pledge is available
  #def most_recent_pledge
  #  pledges.order('created_at DESC').limit(1).first
  #end

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
    return false if pregnancy.pledge_sent || pregnancy.resolved_without_dcaf
    recent_history_tracks.sort.reverse.each do |history|
      return true if history.marked_urgent?
    end
    false
  end

  def assemble_audit_trails
    (history_tracks | pregnancy.history_tracks).sort_by(&:created_at)
                                               .reverse
  end

  # Search-related stuff
  class << self
    # Case insensitive and phone number format agnostic!
    def search(name_or_phone_str, lines = LINES)
      # lines should be an array of symbols
      name_regexp = /#{Regexp.escape(name_or_phone_str)}/i
      clean_phone = name_or_phone_str.gsub(/\D/, '')
      phone_regexp = /#{Regexp.escape(clean_phone)}/

      all_matching_names = find_name_matches name_regexp, lines
      all_matching_phones = find_phone_matches phone_regexp, lines

      (all_matching_names | all_matching_phones)
    end

    private

    def find_name_matches(name_regexp, lines = LINES)
      if nonempty_regexp? name_regexp
        primary_names = Patient.in(_line: lines).where name: name_regexp
        other_names = Patient.in(_line: lines).where other_contact: name_regexp
        return (primary_names | other_names)
      end
      []
    end

    def find_phone_matches(phone_regexp, lines = LINES)
      if nonempty_regexp? phone_regexp
        primary_phones = Patient.in(_line: lines).where(primary_phone: phone_regexp)
        other_phones = Patient.in(_line: lines).where(other_phone: phone_regexp)
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

  def recent_history_tracks
    history_tracks.select { |ht| ht.updated_at > 6.days.ago }
  end

  def confirm_appointment_after_initial_call
    if appointment_date.present? && initial_call_date > appointment_date
      errors.add(:appointment_date, 'must be after date of initial call')
    end
  end

  def clean_fields
    primary_phone.gsub!(/\D/, '') if primary_phone
    other_phone.gsub!(/\D/, '') if other_phone
    name.strip! if name
    other_contact.strip! if other_contact
    other_contact_relationship.strip! if other_contact_relationship
  end
end
