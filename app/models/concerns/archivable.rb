require 'csv'

# TODO test to confirm that specific blacklisted fields aren't being exported

module Archivable
  extend ActiveSupport::Concern

  # How to handle fields found on patient.
  # Anything found that isn't specified will be shredded and complained about.
  PATIENT_ARCHIVE_REFERENCE = {
    :special_circumstances        => method(:shred),
    :name                         => method(:shred),
    :primary_phone                => method(:shred),
    :other_contact                => method(:shred),
    :other_phone                  => method(:shred),
    :other_contact_relationship   => method(:shred),
    :household_size_adults        => method(:shred),
    :household_size_children      => method(:shred),
    :referred_by                  => method(:shred),
    :identifier                   => method(:scramble),
    :age                          => method(:convert_age),
    :fulfillment                  => method(:archive_fulfillment),
    :calls                        => method(:archive_calls),
    :notes                        => method(:archive_notes),
    :archived                     => method(:save),
    :age_range                    => method(:save),
    :_id                          => method(:save),
    :voicemail_preference         => method(:save),
    :line                         => method(:save),
    :language                     => method(:save),
    :initial_call_date            => method(:save),
    :last_menstrual_period_weeks  => method(:save),
    :last_menstrual_period_days   => method(:save),
    :created_at                   => method(:save),
    :created_by_id                => method(:save),
    :updated_at                   => method(:save),
    :version                      => method(:save),
    :appointment_date             => method(:save),
    :race_ethnicity               => method(:save),
    :city                         => method(:save),
    :state                        => method(:save),
    :county                       => method(:save),
    :employment_status            => method(:save),
    :income                       => method(:save),
    :insurance                    => method(:save),
    :referred_to_clinic           => method(:save),
    :resolved_without_fund        => method(:save),
    :clinic_id                    => method(:save),
    :urgent_flag                  => method(:save),
    :procedure_cost               => method(:save),
    :patient_contribution         => method(:save),
    :naf_pledge                   => method(:save),
    :fund_pledge                  => method(:save),
    :pledge_sent                  => method(:save),
    :pledge_generated_at          => method(:save),
    :pledge_generated_by_id       => method(:save),
    :external_pledges             => method(:save),
  }.freeze

  FULFILLMENT_ARCHIVE_REFERENCE = {
    :check_number           => method(:shred),
    :_id                    => method(:save),
    :created_by_id          => method(:save),
    :updated_at             => method(:save),
    :created_at             => method(:save),
    :version                => method(:save),
    :fulfilled              => method(:save),
    :procedure_date         => method(:save),
    :gestation_at_procedure => method(:save),
    :procedure_cost         => method(:save),
    :date_of_check          => method(:save),
  }.freeze

  NOTES_ARCHIVE_REFERENCE = {
    :full_text     => method(:shred),
    :_id           => method(:save),
    :created_at    => method(:save),
    :created_by_id => method(:save),
    :updated_at    => method(:save),
    :version       => method(:save),
  }.freeze

  PLEDGES_ARCHIVE_REFERENCE = {
    :_id           => method(:save),
    :active        => method(:save),
    :source        => method(:save),
    :amount        => method(:save),
    :created_at    => method(:save),
    :created_by_id => method(:save),
    :updated_at    => method(:save),
    :version       => method(:save),
  }.freeze


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

  def save
    # field can be returned as is
    # no action necesary, just avoids flagging to delete
  end

  def shred(field)
    # TODO field should be removed entirely
  end

  def scramble(field)
    # TODO field should be one-way hashed (with salt)
  end

  def archive!
    patient.attributes.keys do |field|
    # lookup action for key in hash
    # if hash key doesn't exist, delete it and log a warning to update the hash!
    end
    # DUMMY
    # TODO erase fields
    # TODO scramble un-erasable fields
    patient.archived = true
  end

  class_methods do
    def unarchived
      Patient.where(archived: :false)
    end

    def archive
      Patient.ready_to_archive do |patient|
        patient.archive!
      end
    end


  end

  private
    def ready_to_archive
      # Final times TODO
      # should I avoid archiving patients from a year ago,
      # with recent call activity...?
      dropped_off_patients = Patient.initial_call_date(1.year.ago)
      completed_patients = Patient.fulfilled_on_or_before(120.days.ago)

      dropped_off_patients + completed_patients
    end

    def archived?
      archived.present? && archived
    end

    # validator
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
