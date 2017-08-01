require 'csv'

# Methods pertaining to patient export
module Archivable
  extend ActiveSupport::Concern
  # Only these fields will survive the purge
  PATIENT_ARCHIVE_SAFE = {
    "BSON ID" => :id,
    "Archived" => :archived, #new field
    "Line" => :line,
    "Age" => :age_range,
#    "Race/Ethnicity" => :race_ethnicity,
#    "Spanish?" => :spanish,
#    "Voicemail Preference" => :voicemail_preference,
#    "State" => :state,
#    "County" => :county,
#    "City" => :city,
#    "Has Alt Contact?" => :has_alt_contact?, #new field
#
#    "Employment Status" => :employment_status,
#    "Insurance" => :insurance,
#    "Income" => :income,
#    "Referred By" => :referred_by,
#    "Referred to clinic by fund" => :referred_to_clinic,
#    "Appointment Date" => :appointment_date,
#    "Initial Call Date" => :initial_call_date,
#    "Urgent?" => :urgent_flag,
#    "LMP at intake (weeks)" => :last_menstrual_period_weeks,
#    "Race or Ethnicity" => :race_ethnicity,
#    "Employment status" => :employment_status,
#    "Abortion cost" => :procedure_cost,
#    "Patient contribution" => :patient_contribution,
#    "NAF pledge" => :naf_pledge,
#    "Fund pledge" => :fund_pledge,
#    "Clinic" => :export_clinic_name,
#    "Pledge sent" => :pledge_sent,
#    "Resolved without fund assistance" => :resolved_without_fund,
#    "Pledge generated time" => :pledge_generated_at

    # TODO clinic stuff
    # TODO call stuff
    # TODO fulfillment stuff
    # TODO external pledges
    # TODO test to confirm that specific blacklisted fields aren't being exported
  }.freeze

  def fulfilled
    fulfillment.try :fulfilled
  end

  def procedure_date
    fulfillment.try :procedure_date
  end

  def gestation_at_procedure
    fulfillment.try :gestation_at_procedure
  end

  def procedure_cost_amount
    fulfillment.try :procedure_cost
  end

  def check_number
    fulfillment.try :check_number
  end

  def date_of_check
    fulfillment.try :date_of_check
  end

  def first_call_timestamp
    calls.first.try :created_at
  end

  def last_call_timestamp
    calls.last.try :created_at
  end

  def call_count
    calls.count
  end

  def reached_patient_call_count
    reached_calls = calls.select {|call| call.status == "Reached patient"}
    reached_calls.count
  end

  def has_alt_contact?
    other_contact.present? || other_phone.present? || other_contact_relationship.present?
  end

  def export_clinic_name
    clinic.try :name
  end

  def age_range
    case age
    when nil, ''
      nil
    when 1..17
      'Under 18'
    when 18..24
      '18-24'
    when 25..34
      '25-34'
    when 35..44
      '35-44'
    when 45..54
      '45-54'
    when 55..100
      '55+'
    else
      'Bad value'
    end
  end

  def preferred_language
    case language
    when nil, ''
      'English'
    else
      language
    end
  end

  def get_field_value_for_serialization(field)
    value = public_send(field)
    if value.is_a?(Array)
      # Use simpler serialization for Array values than the default (`to_s`)
      value.reject(&:blank?).join(', ')
    else
      value
    end
  end

  class_methods do
    def unarchived
      Patient.where(archived: :false)
    end

    def archive
      Patient.ready_to_archive do |patient|
        # DUMMY
        # TODO erase fields
        # TODO scramble un-erasable fields
        patient.archived = true
      end
    end

  end

  private
    def ready_to_archive
      # Final times TODO
      # should I avoid archiving patients from a year ago, with recent call activity...?
      dropped_off_patients = Patient.initial_call_date(1.year.ago)
      completed_patients = Patient.fulfilled_on_or_before(120.days.ago)

      dropped_off_patients + completed_patients
    end

    def archived?
      archived.present? && archived
    end

    def archived_state
      # Dummy implementation
      archived?

      ## should be blank
      #:name,
      #:primary_phone,
      #:other_phone,
      #:age,
      #:contact_name,
      #:circumstances,
      #presence: false
      ## should be scrambled
      #:identifier
      ## should not have any
      #:notes
      #:
      ## fulfillment shouldnt have
      #:check_number

      ## should have
      #:age_range
      #:had_other_contact
    end
end

#  CSV_EXPORT_FIELDS = {
#    "BSON ID" => :id,
#    # "Identifier" => :identifier,
#    "Has Alt Contact?" => :has_alt_contact?,
#    "Voicemail Preference" => :voicemail_preference,
#    "Line" => :line,
#    "Language" => :preferred_language,
#    "Age" => :age_range,
#    "State" => :state,
#    "County" => :county,
#    "Race or Ethnicity" => :race_ethnicity,
#    "Employment Status" => :employment_status,
#    "Minors in Household" => :household_size_children,
#    "Adults in Household" => :household_size_adults,
#    "Insurance" => :insurance,
#    "Income" => :income,
#    "Referred By" => :referred_by,
#    "Referred to clinic by fund" => :referred_to_clinic,
#    "Appointment Date" => :appointment_date,
#    "Initial Call Date" => :initial_call_date,
#    "Urgent?" => :urgent_flag,
#    # "Special Circumstances" => :special_circumstances,
#    "LMP at intake (weeks)" => :last_menstrual_period_weeks,
#    "Abortion cost" => :procedure_cost,
#    "Patient contribution" => :patient_contribution,
#    "NAF pledge" => :naf_pledge,
#    "Fund pledge" => :fund_pledge,
#    "Clinic" => :export_clinic_name,
#    "Pledge sent" => :pledge_sent,
#    "Resolved without fund assistance" => :resolved_without_fund,
#    "Pledge generated time" => :pledge_generated_at,
#
#    # Call related
#    "Timestamp of first call" => :first_call_timestamp,
#    "Timestamp of last call" => :last_call_timestamp,
#    "Call count" => :call_count,
#    "Reached Patient call count" => :reached_patient_call_count,
#
#    # Fulfillment related
#    "Fulfilled" => :fulfilled,
#    "Procedure date" => :procedure_date,
#    "Gestation at procedure in weeks" => :gestation_at_procedure,
#    "Procedure cost" => :procedure_cost,
#    "Check number" => :check_number,
#    "Date of Check" => :date_of_check
#
#    # TODO clinic stuff
#    # TODO external pledges
#    # TODO test to confirm that specific blacklisted fields aren't being exported
#  }.freeze


