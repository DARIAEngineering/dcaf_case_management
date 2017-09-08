require 'csv'

# TODO test to confirm that specific blacklisted fields aren't being exported

module Archivable
  extend ActiveSupport::Concern

  # How to handle fields found on patient.
  # Anything found that isn't specified will be shredded and complained about.
  PATIENT_ARCHIVE_REFERENCE = {
    'special_circumstances'       => :shred,
    'name'                        => :shred,
    'primary_phone'               => :shred,
    'other_contact'               => :shred,
    'other_phone'                 => :shred,
    'other_contact_relationship'  => :shred,
    'household_size_adults'       => :shred,
    'household_size_children'     => :shred,
    'referred_by'                 => :shred,
    'age'                         => :shred,
    'identifier'                  => :scramble,
    'fulfillment'                 => :archive_fulfillment,
    'calls'                       => :archive_calls,
    'notes'                       => :archive_notes,
    'external_pledges'            => :archive_pledges,
    'archived'                    => :keep,
    'age_range'                   => :keep,
    '_id'                         => :keep,
    'voicemail_preference'        => :keep,
    'line'                        => :keep,
    'language'                    => :keep,
    'initial_call_date'           => :keep,
    'last_menstrual_period_weeks' => :keep,
    'last_menstrual_period_days'  => :keep,
    'created_at'                  => :keep,
    'created_by_id'               => :keep,
    'updated_at'                  => :keep,
    'version'                     => :keep,
    'appointment_date'            => :keep,
    'race_ethnicity'              => :keep,
    'city'                        => :keep,
    'state'                       => :keep,
    'county'                      => :keep,
    'employment_status'           => :keep,
    'income'                      => :keep,
    'insurance'                   => :keep,
    'referred_to_clinic'          => :keep,
    'resolved_without_fund'       => :keep,
    'clinic_id'                   => :keep,
    'urgent_flag'                 => :keep,
    'procedure_cost'              => :keep,
    'patient_contribution'        => :keep,
    'naf_pledge'                  => :keep,
    'fund_pledge'                 => :keep,
    'pledge_sent'                 => :keep,
    'pledge_generated_at'         => :keep,
    'pledge_generated_by_id'      => :keep,
  }.freeze


  def has_alt_contact?
    other_contact.present? || other_phone.present? || other_contact_relationship.present?
  end

  def set_age_range
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

  def shred(field)
    self[field.to_sym] = nil
  end

  def scramble(field)
    self[field.to_sym] = SecureRandom.uuid
  end

  def archive_fulfillment(field)
    self.fulfillment.archive!
  end

  # TODO these archive calls are almost all identical
  # on all the models. Abstract out somehow?
  def archive_calls(field)
    self.calls.each do |call|
      call.archive!
    end
  end

  def archive_notes(field)
    self.notes.each do |note|
      note.archive!
    end
  end

  def archive_pledges(field)
    self.external_pledges.each do |pledge|
      pledge.archive!
    end
  end


  def archive!
    self.archived = true
    self.had_other_contact = self.has_alt_contact?
    self.age_range = self.set_age_range

    self.attributes.keys.each do |field|
      if PATIENT_ARCHIVE_REFERENCE.has_key?(field)
        action = PATIENT_ARCHIVE_REFERENCE[field]
        if action == :keep
          #puts "Found a keep! (#{field})"
          next
        elsif self.respond_to?(action) # long term
          #puts "Found a #{action} for field #{field}!"
          self.send(action, field)
        else
          logger.warn "Func '#{action}' for field '#{field}' not found. Shredding"
          #puts "Func '#{action}' for field '#{field}' not found. Shredding"
          self.shred(field)
        end
      else
        logger.warn "Found unaccounted for key '#{field}' when archiving. " \
                    "Shredding the content of this field. Please add proper " \
                    "handling for the field in the archive concern"
        self.shred(field)
      end
    end
    save
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
      validate :name,
               :special_circumstances,
               :primary_phone,
               :other_contact,
               :other_phone,
               :other_contact_relationship,
               :household_size_adults,
               :household_size_children,
               :referred_by,
               :age, presence: false

      # Identifier should look like a UUID
      validate :identifier,
        format: /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/

      validate :age_range,
               :had_other_contact,
               presence: true

      ## fulfillment shouldnt have
      #:check_number
    end
end
