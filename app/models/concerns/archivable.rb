require 'csv'

# TODO test to confirm that specific blacklisted fields aren't being exported

module Archivable
  extend ActiveSupport::Concern

  # How to handle fields found on patient.
  # Anything found that isn't specified will be shredded and complained about.
  PATIENT_ARCHIVE_REFERENCE = {
    :special_circumstances        => :shred,
    :name                         => :shred,
    :primary_phone                => :shred,
    :other_contact                => :shred,
    :other_phone                  => :shred,
    :other_contact_relationship   => :shred,
    :household_size_adults        => :shred,
    :household_size_children      => :shred,
    :referred_by                  => :shred,
    :identifier                   => :scramble,
    :age                          => :convert_age,
    :fulfillment                  => :archive_fulfillment,
    :calls                        => :archive_calls,
    :notes                        => :archive_notes,
    :external_pledges             => :archive_pledges,
    :archived                     => :save,
    :age_range                    => :save,
    :_id                          => :save,
    :voicemail_preference         => :save,
    :line                         => :save,
    :language                     => :save,
    :initial_call_date            => :save,
    :last_menstrual_period_weeks  => :save,
    :last_menstrual_period_days   => :save,
    :created_at                   => :save,
    :created_by_id                => :save,
    :updated_at                   => :save,
    :version                      => :save,
    :appointment_date             => :save,
    :race_ethnicity               => :save,
    :city                         => :save,
    :state                        => :save,
    :county                       => :save,
    :employment_status            => :save,
    :income                       => :save,
    :insurance                    => :save,
    :referred_to_clinic           => :save,
    :resolved_without_fund        => :save,
    :clinic_id                    => :save,
    :urgent_flag                  => :save,
    :procedure_cost               => :save,
    :patient_contribution         => :save,
    :naf_pledge                   => :save,
    :fund_pledge                  => :save,
    :pledge_sent                  => :save,
    :pledge_generated_at          => :save,
    :pledge_generated_by_id       => :save,
  }.freeze

  FULFILLMENT_ARCHIVE_REFERENCE = {
    :check_number           => :shred,
    :_id                    => :save,
    :created_by_id          => :save,
    :updated_at             => :save,
    :created_at             => :save,
    :version                => :save,
    :fulfilled              => :save,
    :procedure_date         => :save,
    :gestation_at_procedure => :save,
    :procedure_cost         => :save,
    :date_of_check          => :save,
  }.freeze

  NOTES_ARCHIVE_REFERENCE = {
    :full_text     => :shred,
    :_id           => :save,
    :created_at    => :save,
    :created_by_id => :save,
    :updated_at    => :save,
    :version       => :save,
  }.freeze

  PLEDGES_ARCHIVE_REFERENCE = {
    :_id           => :save,
    :active        => :save,
    :source        => :save,
    :amount        => :save,
    :created_at    => :save,
    :created_by_id => :save,
    :updated_at    => :save,
    :version       => :save,
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

  def convert_age
  end

  # TODO fix
  def archive_fulfillment
    attributes.keys do |field|
      if FULFILLMENT_ARCHIVE_REFERENCE.has_key(field.to_sym)
        action = FULFILLMENT_ARCHIVE_REFERENCE[field.to_sym]
        if respond_to?(action)
          send(action, field)
        else
          logger.warn "Func '#{action}' for field'#{field}' not found. Shredding"
          shred(field)
        end
      else
        logger.warn "Found unaccounted for key '#{field}' when archiving. " \
                    "Shredding the content of this field. Please add proper " \
                    "handling for the field in the archive concern"
        shred(field)
      end
    end

  end

  # TODO fix
  def archive_calls
    attributes.keys do |field|
      if CALLS_ARCHIVE_REFERENCE.has_key(field.to_sym)
        action = CALLS_ARCHIVE_REFERENCE[field.to_sym]
        if respond_to?(action)
          send(action, field)
        else
          logger.warn "Func '#{action}' for field'#{field}' not found. Shredding"
          shred(field)
        end
      else
        logger.warn "Found unaccounted for key '#{field}' when archiving. " \
                    "Shredding the content of this field. Please add proper " \
                    "handling for the field in the archive concern"
        shred(field)
      end
    end

  end

  # TODO fix
  def archive_notes
    attributes.keys do |field|
      if NOTES_ARCHIVE_REFERENCE.has_key(field.to_sym)
        action = NOTES_ARCHIVE_REFERENCE[field.to_sym]
        if respond_to?(action)
          send(action, field)
        else
          logger.warn "Func '#{action}' for field'#{field}' not found. Shredding"
          shred(field)
        end
      else
        logger.warn "Found unaccounted for key '#{field}' when archiving. " \
                    "Shredding the content of this field. Please add proper " \
                    "handling for the field in the archive concern"
        shred(field)
      end
    end

  end

  # TODO fix
  def archive_pledges
    attributes.keys do |field|
      if PLEDGES_ARCHIVE_REFERENCE.has_key(field.to_sym)
        action = PLEDGES_ARCHIVE_REFERENCE[field.to_sym]
        if respond_to?(action)
          send(action, field)
        else
          logger.warn "Func '#{action}' for field'#{field}' not found. Shredding"
          shred(field)
        end
      else
        logger.warn "Found unaccounted for key '#{field}' when archiving. " \
                    "Shredding the content of this field. Please add proper " \
                    "handling for the field in the archive concern"
        shred(field)
      end
    end


  end

  def archive!
    attributes.keys do |field|
      if PATIENT_ARCHIVE_REFERENCE.has_key(field.to_sym)
        action = PATIENT_ARCHIVE_REFERENCE[field.to_sym]
        if respond_to?(action)
          send(action, field)
        else
          logger.warn "Func '#{action}' for field'#{field}' not found. Shredding"
          shred(field)
        end
      else
        logger.warn "Found unaccounted for key '#{field}' when archiving. " \
                    "Shredding the content of this field. Please add proper " \
                    "handling for the field in the archive concern"
        shred(field)
      end
    end
    had_other_contact = has_alt_contact?
    archived = true
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
