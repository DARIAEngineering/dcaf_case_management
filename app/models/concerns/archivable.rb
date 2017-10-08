require 'csv'

# TODO test to confirm that specific blacklisted fields aren't being exported

module Archivable
  extend ActiveSupport::Concern

  # How to handle fields found on patient.
  # Anything found that isn't specified will be shredded and complained about.
  PATIENT_ARCHIVE_REFERENCE = {
    'special_circumstances'       => :empty,
    'primary_phone'               => :shred,
    'other_contact'               => :shred,
    'other_phone'                 => :shred,
    'other_contact_relationship'  => :shred,
    'household_size_adults'       => :shred,
    'household_size_children'     => :shred,
    'referred_by'                 => :shred,
    'age'                         => :shred,
    'name'                        => :overwrite,
    'identifier'                  => :scramble,
    'fulfillment'                 => :archive_fulfillment,
    'calls'                       => :archive_calls,
    'notes'                       => :archive_notes,
    'external_pledges'            => :archive_pledges,
    'archived'                    => :keep,
    'age_range'                   => :keep,
    'had_other_contact'           => :keep,
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
      :unknown
    when 1..17
      :under_18
    when 18..24
      :age18_24
    when 25..34
      :age25_34
    when 35..44
      :age35-44
    when 45..54
      :age45_54
    when 55..100
      :age55_100
    else
      'Bad value'
    end
  end

  def shred(field)
    self[field.to_sym] = nil
  end

  def empty(field)
    self[field.to_sym] = []
  end

  def scramble(field)
    self[field.to_sym] = SecureRandom.uuid
  end

  def overwrite(field)
    self[field.to_sym] = "ARCHIVED"
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
    self.age_range = set_age_range

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
    self.save
  end


  class_methods do
    def ready_to_archive
      # Final times TODO
      # should I avoid archiving patients from a year ago,
      # with recent call activity...?
      dropped_off_patients = Patient.where(:initial_call_date.lte => 1.year.ago)
      completed_patients = Patient.fulfilled_on_or_before(120.days.ago)

      dropped_off_patients + completed_patients
    end


    #scope :english, ->{ where(country: "England") }
    #def unarchived
      ## TODO change to scope and acutally call this
      #Patient.where(archived: :false)
    #end

    def archive
      ready_to_archive.each do |patient|
        patient.archive!
      end
    end
  end

  def archived?
    archived.present? && archived
  end

  private
    # validator
    def archived_state
      if name.present? && name != "ARCHIVED"
        errors.add(:name, "should be overwritten for archived patients")
      end
      if special_circumstances.present? && ! special_circumstances.nil?
        errors.add(:special_circumstances, "should be nil for archived patients")
      end
      if primary_phone.present? && ! primary_phone.nil?
        errors.add(:primary_phone, "should be nil for archived patients")
      end
      if other_contact.present? && ! other_contact.nil?
        errors.add(:other_contact, "should be nil for archived patients")
      end
      if other_phone.present? && ! other_phone.nil?
        errors.add(:other_phone, "should be nil for archived patients")
      end
      if household_size_adults.present? && ! household_size_adults.nil?
        errors.add(:household_size_adults, "should be nil for archived patients")
      end
      if household_size_children.present? && ! household_size_children.nil?
        errors.add(:household_size_children, "should be nil for archived patients")
      end
      if referred_by.present? && ! referred_by.nil?
        errors.add(:referred_by, "should be nil for archived patients")
      end
      if age.present? && ! age.nil?
        errors.add(:age, "should be nil for archived patients")
      end

      # Identifier should look like a UUID
      unless ( identifier =~ /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/)
        errors.add(:identifier, "should be a UUID for archived patients")
      end

      if age_range.nil?
        errors.add(:age_range, "should be set for archived patients")
      end
      if had_other_contact.nil?
        errors.add(:had_other_contact, "should be set for archived patients")
      end

      ## fulfillment shouldnt have
      #:check_number
    end

end
