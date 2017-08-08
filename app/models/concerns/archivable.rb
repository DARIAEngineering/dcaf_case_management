require 'csv'

# Methods pertaining to patient export
module Archivable
  extend ActiveSupport::Concern

  def has_alt_contact?
    other_contact.present? || other_phone.present? || other_contact_relationship.present?
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

  class_methods do
    def unarchived
      Patient.where(archived: :false)
    end

    def archive
      Patient.ready_to_archive do |patient|
        patient.attributes.keys do |field|
          # lookup action for key in hash
          # if hash key doesn't exist, delete it and log a warning to update the hash!
        end
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

#  # Only these fields will survive the purge
#  TODO : mark as Save, Scramble, Clear, Transform
#
  PATIENT_ARCHIVE_SAFE = {
    "BSON ID" => :id,
    "Archived" => :archived, #new field
    "Line" => :line,
    "Age" => :age_range,
    "Race/Ethnicity" => :race_ethnicity,
    "Spanish?" => :spanish,
    "Voicemail Preference" => :voicemail_preference,
    "State" => :state,
    "County" => :county,
    "City" => :city,
    "Has Alt Contact?" => :has_alt_contact?, #new field

    "Employment Status" => :employment_status,
    "Insurance" => :insurance,
    "Income" => :income,
    "Referred By" => :referred_by,
    "Referred to clinic by fund" => :referred_to_clinic,
    "Appointment Date" => :appointment_date,
    "Initial Call Date" => :initial_call_date,
    "Urgent?" => :urgent_flag,
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

