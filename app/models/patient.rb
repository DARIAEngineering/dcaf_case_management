# Object representing core patient information and demographic data.
class Patient < ApplicationRecord
  acts_as_tenant :fund

  # Concerns
  include PaperTrailable
  include Shareable
  include Callable
  include Notetakeable
  include PatientSearchable
  include AttributeDisplayable
  include LastMenstrualPeriodMeasureable
  include Pledgeable
  include Statusable
  include Exportable
  include EventLoggable

  # Callbacks
  before_validation :clean_fields
  before_save :save_identifier
  before_save :update_pledge_sent_by_sent_at
  before_save :update_fund_pledged_at
  after_create :initialize_fulfillment
  after_update :confirm_still_shared, if: :shared_flag?
  after_update :update_call_list_lines, if: :saved_change_to_line_id?
  after_destroy :destroy_associated_events

  # Relationships
  belongs_to :line
  has_many :call_list_entries, dependent: :destroy
  has_many :users, through: :call_list_entries
  belongs_to :clinic, optional: true
  has_one :fulfillment, as: :can_fulfill
  has_many :calls, as: :can_call
  has_many :external_pledges, as: :can_pledge
  has_many :practical_supports, as: :can_support
  has_many :notes, as: :can_note
  belongs_to :pledge_generated_by, class_name: 'User', inverse_of: nil, optional: true
  belongs_to :pledge_sent_by, class_name: 'User', inverse_of: nil, optional: true
  belongs_to :last_edited_by, class_name: 'User', inverse_of: nil, optional: true

  # Enable mass posting in forms
  accepts_nested_attributes_for :fulfillment

  # Validations
  # Worry about uniqueness to tenant after porting line info.
  # validates_uniqueness_to_tenant :primary_phone
  validates :name,
            :primary_phone,
            :initial_call_date,
            :line,
            presence: true
  validates :primary_phone, format: /\A\d{10}\z/,
                            length: { is: 10 }
  validate :confirm_unique_phone_number
  validates :other_phone, format: /\A\d{10}\z/,
                          length: { is: 10 },
                          allow_blank: true
  validates :appointment_date, format: /\A\d{4}-\d{1,2}-\d{1,2}\z/,
                               allow_blank: true
  validate :confirm_appointment_after_initial_call
  validate :pledge_sent, :pledge_info_presence, if: :updating_pledge_sent?
  validates :last_menstrual_period_weeks,
            :last_menstrual_period_days,
            :age,
            :procedure_cost,
            :fund_pledge,
            :naf_pledge,
            :patient_contribution,
            numericality: { only_integer: true, allow_nil: true, greater_than_or_equal_to: 0 }
  validates :household_size_adults, :household_size_children, numericality: { only_integer: true, allow_nil: true, greater_than_or_equal_to: -1 }
  validates :name, :primary_phone, :other_contact, :other_phone, :other_contact_relationship,
            :voicemail_preference, :language, :pronouns, :city, :state, :county, :zipcode,
            :race_ethnicity, :employment_status, :insurance, :income, :referred_by, :solidarity_lead, :procedure_type,
            length: { maximum: 150 }
  validates_associated :fulfillment

  # validation for standard US zipcodes
  # allow ZIP (NNNNN) or ZIP+4 (NNNNN-NNNN)
  validates :zipcode, format: /\A\d{5}(-\d{4})?\z/,
            length: {minimum: 5, maximum: 10},
            allow_blank: true

  validate :special_circumstances_length

  # Methods
  def self.pledged_status_summary(line)
    plucked_attrs = [:fund_pledge, :pledge_sent, :id, :name, :appointment_date, :fund_pledged_at]
    start_of_period = Config.start_day.downcase.to_s == "monthly" ? Time.zone.today.beginning_of_month.in_time_zone(Config.time_zone)
                                                                  : Time.zone.today.beginning_of_week(Config.start_day).in_time_zone(Config.time_zone)
    # Get patients who have been pledged this week, as a simplified hash
    base = Patient.where(line: line,
                         resolved_without_fund: [false, nil])
                  .where.not(fund_pledge: [0, nil])

    patients = base.where(pledge_sent_at: start_of_period..)
                   .or(base.where(fund_pledged_at: start_of_period..))
                   .order(fund_pledged_at: :asc)
                   .select(*plucked_attrs)

    # Divide people up based on whether pledges have been sent or not
    patients.each_with_object(sent: [], pledged: []) do |patient, summary|
      if patient.pledge_sent?
        summary[:sent] << patient
      else
        summary[:pledged] << patient
      end
      summary
    end
  end

  def save_identifier
    #[Line first initial][Phone 6th digit]-[Phone last four]
    self.identifier = "#{line.name[0].upcase}#{primary_phone[-5]}-#{primary_phone[-4..-1]}"
  end

  def initials
    name.split(' ').map { |part| part[0] }.join('')
  end

  def event_params
    {
      event_type:    'pledged',
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
    Event.where(patient_id: id).destroy_all
    CallListEntry.where(patient_id: id).destroy_all
  end

  def update_call_list_lines
    CallListEntry.where(patient: self)
                 .update(line: self.line, order_key: 999)
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

      patients_line = phone_match.line
      volunteers_line = line
      if volunteers_line == patients_line
        errors.add(:this_phone_number_is_already_taken, "on this line.")
      else
        errors.add(:this_phone_number_is_already_taken, "on the #{patients_line.name} line. If you need the patient's line changed, please contact the CM directors.")
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
    notes.size
  end

  def has_special_circumstances
    special_circumstances.map { |circumstance| circumstance.present? }.any?
  end

  def archive_date
    if fulfillment.audited?
      # If a patient fulfillment is ticked off as audited, archive 3 months
      # after initial call date. If we're already past 3 months later when
      # the audit happens, it will archive that night
      initial_call_date + Config.archive_fulfilled_patients.days
    else
      # If a patient is waiting for audit they archive a year after their
      # initial call date
      initial_call_date + Config.archive_all_patients.days
    end
  end

  def recent_history_tracks
    versions.where(updated_at: 6.days.ago..)
  end

  def all_versions(include_fulfillment)
    all_versions = versions || []
    all_versions += (external_pledges.includes(versions: [:item, :user]).map(&:versions).reduce(&:+) || [])
    all_versions += (practical_supports.includes(versions: [:item, :user]).map(&:versions).reduce(&:+) || [])
    if include_fulfillment
      all_versions += (fulfillment.versions.includes(fulfillment.versions.count > 1 ? [:item, :user] : []) || [])
    end
    all_versions.sort_by(&:created_at).reverse
  end

  # when we update the patient async (via React), we return the updated patient as json
  # as_json will return the AR attributes stored in the db by default
  # we extend it here to also include some of the additional custom getters we've written
  # (that aren't stored in the db but are derived from db values)
  def as_json
    super.merge(
      status: status,
      last_menstrual_period_at_appt_weeks: last_menstrual_period_at_appt_weeks,
      last_menstrual_period_at_appt_days: last_menstrual_period_at_appt_days,
      last_menstrual_period_now_weeks: last_menstrual_period_now_weeks,
      last_menstrual_period_now_days: last_menstrual_period_now_days,
      primary_phone_display: primary_phone_display,
      initial_call_date_display: initial_call_date.strftime('%m/%d/%Y')
    )
  end

  private

  def confirm_appointment_after_initial_call
    if appointment_date.present? && initial_call_date.present? && (initial_call_date - 60.days)&.send(:>, appointment_date)
      errors.add(:appointment_date, 'must be closer to the date of initial call')
    end
  end

  def clean_fields
    primary_phone.gsub!(/\D/, '') if primary_phone
    other_phone.gsub!(/\D/, '') if other_phone
    name.strip! if name
    other_contact.strip! if other_contact
    other_contact_relationship.strip! if other_contact_relationship

    # add dash if needed
    zipcode.gsub!(/(\d{5})(\d{4})/, '\1-\2') if zipcode
  end

  def initialize_fulfillment
    build_fulfillment.save
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
    if fund_pledge_changed? && fund_pledge && !fund_pledged_at
      self.fund_pledged_at = Time.zone.now
    elsif fund_pledge.blank?
      self.fund_pledged_at = nil
    end
  end

  def self.fulfilled_on_or_before(datetime)
    Patient.where('fulfillment.fulfilled' => true,
                  updated_at: { '$lte' => datetime })
  end

  def self.unconfirmed_practical_support(line)
    Patient.distinct
           .where(line: line)
           .joins(:practical_supports)
           .where({ practical_supports: { confirmed: false }, created_at: 3.months.ago.. })
  end

  # This is intended to protect against saving maliscious data sent via an edited request. It should
  # not be possible to trigger errors here via the UI.
  def special_circumstances_length
    # The max length is (2 x n) where n is the number of special circumstances checkboxes. With no
    # boxes checked, there are n elements (all blank), and there is an additional element present
    # for every checked box.
    errors.add(:special_circumstances, 'is invalid') unless special_circumstances.length <= 14

    special_circumstances.each do |value|
      errors.add(:special_circumstances, 'is invalid') if value && value.length > 50
    end
  end
end
