class Pregnancy
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp
  include LastMenstrualPeriodHelper

  # relationships
  belongs_to :patient
  belongs_to :user
  embeds_many :pledges
  embeds_many :notes
  embeds_many :calls
  has_one :clinic

  # for mass posting
  accepts_nested_attributes_for :patient
  accepts_nested_attributes_for :clinic

  # for history and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true

  mongoid_userstamp user_model: 'User'

  # general common intake information
  field :initial_call_date, type: Date
  field :last_menstrual_period_weeks, type: Integer
  field :last_menstrual_period_days, type: Integer

  field :voicemail_ok, type: Boolean
  field :line, type: String # DC, MD, VA
  field :language, type: String
  field :appointment_date, type: Date
  field :urgent_flag, type: Boolean

  # patient general info
  field :age, type: Integer
  field :city, type: String
  field :state, type: String # ennumeration?
  field :zip, type: String
  field :county, type: String
  field :race_ethnicity, type: String
  field :employment_status, type: String
  field :household_size, type: Integer
  field :insurance, type: String
  field :income, type: Integer
  field :referred_by, type: String
  field :special_circumstances, type: String # ennumeration

  # procedure info - generally for administrative use
  field :fax_received, type: Boolean
  field :procedure_cost, type: Integer
  field :procedure_date, type: DateTime
  field :procedure_completed_date, type: DateTime
  field :resolved_without_dcaf, type: Boolean

  def self.most_recent
    order('created_at DESC').limit(1).first
  end

  def recent_calls
    calls.order('created_at DESC').limit(10)
  end

  def old_calls
    calls.order('created_at DESC').offset(10)
  end

  def status
    # if resolved_without_dcaf
    #   status = "Resolved Without DCAF"
    # elsif pledge_status?(:paid)
    #   status = "Pledge Paid"
    # elsif pledge_status?(:sent)
    #   status = "Sent Pledge"
    if appointment_date
      'Fundraising'
    elsif contact_made?
      'Needs Appointment'
    else
      'No Contact Made'
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
