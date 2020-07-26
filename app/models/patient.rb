# Object representing core patient information and demographic data.
class Patient < ApplicationRecord
  # Concerns
  include Urgency
  include Callable
  include Notetakeable
  include PatientSearchable
  include AttributeDisplayable
  include LastMenstrualPeriodMeasureable
  include Pledgeable
  include HistoryTrackable
  include Statusable
  include Exportable
  include EventLoggable

  # Scopes
  LINES.each do |line|
    scope line.downcase.to_sym, -> { where(:line.in => [line]) }
  end

  # Relationships
  belongs_to :clinic
  has_many :calls, as: :can_call
  has_many :external_pledges, as: :can_pledge
  has_many :practical_supports, as: :can_support
  has_many :notes
  has_one :fulfillment, as: :can_fulfill

  # Callbacks
  before_validation :clean_fields
  before_save :save_identifier
  before_update :update_pledge_sent_by_sent_at
  before_save :update_fund_pledged_at
  after_create :initialize_fulfillment
  after_update :confirm_still_urgent, if: :urgent_flag?
  after_destroy :destroy_associated_events

  # Enable mass posting in forms
  # accepts_nested_attributes_for :fulfillment

  # Validations
  validates :name,
            :primary_phone,
            :initial_call_date,
            :created_by_id,
            :line,
            presence: true
  validates :primary_phone, format: /\d{10}/,
                            length: { is: 10 }
  validate :confirm_unique_phone_number
  validates :other_phone, format: /\d{10}/,
                          length: { is: 10 },
                          allow_blank: true
  validates :appointment_date, format: /\A\d{4}-\d{1,2}-\d{1,2}\z/,
                               allow_blank: true
  validate :confirm_appointment_after_initial_call
  validate :pledge_sent, :pledge_info_presence, if: :updating_pledge_sent?
  # validates_associated :fulfillment

  # Methods
  def self.pledged_status_summary(line)
    plucked_attrs = [:fund_pledge, :pledge_sent, :id, :name, :appointment_date, :fund_pledged_at]
    start_of_period = Config.start_day.downcase.to_s == "monthly" ? Time.zone.today.beginning_of_month.in_time_zone
                                                                  : Time.zone.today.beginning_of_week(Config.start_day).in_time_zone
    # Get patients who have been pledged this week, as a simplified hash
    patients = Patient.in(line: line)
                      .where(:fund_pledge.nin => [0, nil, ''])
                      .or({:pledge_sent_at.gte => start_of_period}, {:fund_pledged_at.gte => start_of_period})
                      .where(:resolved_without_fund.in => [false, nil])
                      .order_by(fund_pledged_at: :asc)
                      .pluck(*plucked_attrs)
                      .map { |att| plucked_attrs.zip(att).to_h }
    # Divide people up based on whether pledges have been sent or not
    patients.each_with_object(sent: [], pledged: []) do |patient, summary|
      if patient[:pledge_sent]
        summary[:sent] << patient
      else
        summary[:pledged] << patient
      end
      summary
    end
  end

  def save_identifier
    self.identifier = "#{line[0]}#{primary_phone[-5]}-#{primary_phone[-4..-1]}"
  end

  def initials
    name.split(' ').map { |part| part[0] }.join('')
  end

  def event_params
    {
      event_type:    'Pledged',
      cm_name:       updated_by&.name || 'System',
      patient_name:  name,
      patient_id:    id,
      line:          line,
      pledge_amount: fund_pledge
    }
  end

  def okay_to_destroy?
    !pledge_sent?
  end

  def destroy_associated_events
    Event.where(patient_id: id.to_s).destroy_all
  end

  def confirm_unique_phone_number
    ##
    # This method is preferred over Rail's built-in uniqueness validator
    # so that case managers get a meaningful error message when a patient
    # exists on a different line than the one the volunteer is serving.
    #
    # See https://github.com/DCAFEngineering/dcaf_case_management/issues/825
    ##
    phone_match = Patient.where(primary_phone: primary_phone).first

    if phone_match
      # skip when an existing patient updates and matches itself
      if phone_match.id == self.id
        return
      end

      patients_line = phone_match[:line]
      volunteers_line = line
      if volunteers_line == patients_line
        errors.add(:this_phone_number_is_already_taken, "on this line.")
      else
        errors.add(:this_phone_number_is_already_taken, "on the #{patients_line} line. If you need the patient's line changed, please contact the CM directors.")
      end
    end
  end

  def has_alt_contact
    other_contact.present? || other_phone.present? || other_contact_relationship.present?
  end

  def age_range
    case age
    when nil, ''
      :not_specified
    when 1..17
      :under_18
    when 18..24
      :age18_24
    when 25..34
      :age25_34
    when 35..44
      :age35_44
    when 45..54
      :age45_54
    when 55..100
      :age55plus
    else
      :bad_value
    end
  end

  def notes_count
    notes.count
  end

  def has_special_circumstances
    special_circumstances.map { |circumstance| circumstance.present? }.any?
  end

  def archive_date
    if fulfillment.audited?
      # If a patient fulfillment is ticked off as audited, archive 3 months
      # after initial call date. If we're already past 3 months later when
      # the audit happens, it will archive that night
      initial_call_date + 3.months
    else
      # If a patient is waiting for audit they archive a year after their
      # initial call date
      initial_call_date + 1.year
    end
  end

  private

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

  def initialize_fulfillment
    build_fulfillment(created_by_id: created_by_id).save
  end

  def update_pledge_sent_by_sent_at
    if pledge_sent && !pledge_sent_by
      self.pledge_sent_at = Time.zone.now
      self.pledge_sent_by = last_edited_by
    elsif !pledge_sent
      self.pledge_sent_by = nil
      self.pledge_sent_at = nil
    end
  end

  def update_fund_pledged_at
    if fund_pledge_changed? && fund_pledge
      self.fund_pledged_at = Time.zone.now
    elsif fund_pledge.blank?
      self.fund_pledged_at = nil
    end
  end

  def self.fulfilled_on_or_before(datetime)
    Patient.where('fulfillment.fulfilled' => true,
                  updated_at: { '$lte' => datetime })
  end
end
