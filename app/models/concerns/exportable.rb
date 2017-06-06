require 'csv'

# Methods pertaining to patient export
module Exportable
  extend ActiveSupport::Concern

  CSV_EXPORT_FIELDS = {
    "BSON ID" => :id,
    # "Identifier" => :identifier,
    "Has Alt Contact?" => :has_alt_contact?,
    "Voicemail Preference" => :voicemail_preference,
    "Line" => :line,
    "Spanish?" => :spanish,
    "Age" => :age_range,
    "State" => :state,
    "County" => :county,
    "Race/Ethnicity" => :race_ethnicity,
    "Employment Status" => :employment_status,
    "Minors in Household" => :household_size_children,
    "Adults in Household" => :household_size_adults,
    "Insurance" => :insurance,
    "Income" => :income,
    "Referred By" => :referred_by,
    "Referred to clinic by fund" => :referred_to_clinic,
    "Appointment Date" => :appointment_date,
    "Initial Call Date" => :initial_call_date,
    "Urgent?" => :urgent_flag,
    # "Special Circumstances" => :special_circumstances,
    "LMP at intake (weeks)" => :last_menstrual_period_weeks,
    "Race or Ethnicity" => :race_ethnicity,
    "Employment status" => :employment_status,
    "Abortion cost" => :procedure_cost,
    "Patient contribution" => :patient_contribution,
    "NAF pledge" => :naf_pledge,
    "Fund pledge" => :fund_pledge,
    "Clinic" => :export_clinic_name,
    "Pledge sent" => :pledge_sent,
    "Resolved without fund assistance" => :resolved_without_fund,
    "Pledge generated time" => :pledge_generated_at

    # TODO clinic stuff
    # TODO call stuff
    # TODO fulfillment stuff
    # TODO external pledges
    # TODO test to confirm that specific blacklisted fields aren't being exported
  }.freeze

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
    def to_csv
      CSV.generate(encoding: 'utf-8') do |csv|
        csv << CSV_EXPORT_FIELDS.keys # Header line
        all.each do |patient|
          csv << CSV_EXPORT_FIELDS.values.map do |field|
             patient.get_field_value_for_serialization(field)
          end
        end
      end
    end
  end
end
