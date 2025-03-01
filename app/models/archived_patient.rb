# A PII stripped patient for reporting.
class ArchivedPatient < ApplicationRecord
  acts_as_tenant :fund

  # Concerns
  include PaperTrailable
  include Exportable
  include LastMenstrualPeriodMeasureable

  # Relationships
  belongs_to :clinic, optional: true
  belongs_to :line
  has_one :fulfillment, as: :can_fulfill
  has_many :calls, as: :can_call
  has_many :external_pledges, as: :can_pledge
  has_many :practical_supports, as: :can_support
  belongs_to :pledge_generated_by, class_name: 'User', inverse_of: nil, optional: true
  belongs_to :pledge_sent_by, class_name: 'User', inverse_of: nil, optional: true

  # Enums
  enum :age_range, {
    not_specified: :not_specified,
    under_18: :under_18,
    age18_24: :age18_24,
    age25_34: :age25_34,
    age35_44: :age35_44,
    age45_54: :age45_54,
    age55plus: :age55plus,
    bad_value: :bad_value
  }

  # Validations
  validates :initial_call_date,
            :line,
            presence: true
  validates :appointment_date, format: /\A\d{4}-\d{1,2}-\d{1,2}\z/,
                               allow_blank: true
  validates :last_menstrual_period_weeks,
            :last_menstrual_period_days,
            :procedure_cost,
            :ultrasound_cost,
            :fund_pledge,
            :naf_pledge,
            :patient_contribution,
            numericality: { only_integer: true, allow_nil: true, greater_than_or_equal_to: 0 }
  validates_associated :fulfillment

  # Archive & delete audited patients who called a several months ago, or any
  # from a year plus ago
  def self.archive_eligible_patients!
    Patient.all.each do |patient|
      if ( patient.archive_date < Date.today )
        ActiveRecord::Base.transaction do
          ArchivedPatient.convert_patient(patient)
          patient.destroy!
        end
      end
    end
  end

  # enforce procedure cost must be positive - otherwise nil
  def self.procedure_cost_positive(c)
    if c.present? and c >= 0
      c
    else
      nil
    end
  end

  def self.convert_patient(patient)
    archived_patient = new(
      line: patient.line,
      city: patient.city,
      state: patient.state,
      county: patient.county,
      initial_call_date: patient.initial_call_date,
      appointment_date: patient.appointment_date,
      multiday_appointment: patient.multiday_appointment,
      practical_support_waiver: patient.practical_support_waiver,

      shared_flag: patient.shared_flag,
      referred_by: patient.referred_by,
      referred_to_clinic: patient.referred_to_clinic,

      last_menstrual_period_weeks: patient.last_menstrual_period_weeks,
      last_menstrual_period_days: patient.last_menstrual_period_days,

      race_ethnicity: patient.race_ethnicity,
      employment_status: patient.employment_status,
      insurance: patient.insurance,
      procedure_type: patient.procedure_type,
      income: patient.income,
      language: patient.language,
      voicemail_preference: patient.voicemail_preference,

      patient_contribution: patient.patient_contribution,
      naf_pledge: patient.naf_pledge,
      fund_pledge: patient.fund_pledge,
      fund_pledged_at: patient.fund_pledged_at,
      solidarity: patient.solidarity,
      solidarity_lead: patient.solidarity_lead,

      pledge_sent: patient.pledge_sent,
      resolved_without_fund: patient.resolved_without_fund,
      pledge_generated_at: patient.pledge_generated_at,
      pledge_sent_at: patient.pledge_sent_at,
      textable: patient.textable,

      pledge_generated_by: patient.pledge_generated_by,
      pledge_sent_by: patient.pledge_sent_by,

      age_range: patient.age_range,
      has_alt_contact: patient.has_alt_contact,
      notes_count: patient.notes_count,
      has_special_circumstances: patient.has_special_circumstances,

    )

    archived_patient.clinic_id = patient.clinic_id if patient.clinic_id
    archived_patient.line_id = patient.line_id

    archived_patient.procedure_cost = procedure_cost_positive patient.procedure_cost
    archived_patient.ultrasound_cost = procedure_cost_positive patient.ultrasound_cost

    PaperTrail.request(whodunnit: patient.created_by_id) do
      archived_patient.save!
    end

    patient.versions.destroy_all

    patient.fulfillment.update! can_fulfill: archived_patient

    patient.calls.each do |call|
      call.update! can_call: archived_patient
    end
    patient.external_pledges.each do |ext_pledge|
      ext_pledge.update! can_pledge: archived_patient
    end
    patient.practical_supports.each do |support|
      support.update! can_support: archived_patient
    end

    archived_patient.save!
    archived_patient
  end
end
