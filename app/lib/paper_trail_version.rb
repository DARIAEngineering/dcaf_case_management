# Extensions to base class of PaperTrail.
class PaperTrailVersion < PaperTrail::Version
  acts_as_tenant :fund

  # Relations
  belongs_to :user, foreign_key: :whodunnit, optional: true

  IRRELEVANT_FIELDS = %w[
    id
    user_ids
    updated_by_id
    pledge_sent_by_id
    last_edited_by_id
    identifier
    updated_at
    created_at
    can_pledge_type
    can_pledge_id
    fund_id
    can_fulfill_type
    can_fulfill_id
    can_support_type
    can_support_id
    name
    primary_phone
    other_phone
    other_contact
    other_contact_relationship
    city
    state
    county
    zipcode
  ].freeze
  DATE_FIELDS = %w[
    appointment_date
    initial_call_date
  ].freeze
  TIME_FIELDS = %w[
    pledge_generated_at
    pledge_sent_at
    fund_pledged_at
  ]

  # convenience methods for clean view display
  def date_of_change
    created_at.display_date
  end

  def has_changed_fields?
    object_changes.keys.reject { |x| IRRELEVANT_FIELDS.include? x }.present?
  end

  def changed_by_user
    user&.name || 'System'
  end

  def shaped_changes
    changeset.reject { |field| IRRELEVANT_FIELDS.include? field }
             .reject { |_, values| values[0].blank? && values[1].blank? }
             .reduce({}) do |acc, x|
               key = x[0]
               acc.merge({ key => { original: format_fieldchange(key, x[1][0]),
                                    modified: format_fieldchange(key, x[1][1]) }})
             end
  end

  def marked_shared?
    (object_changes['shared_flag']&.last == true) || (object_changes['urgent_flag']&.last == true)
  end

  def self.destroy_old
    PaperTrailVersion.where("created_at < ?", 1.year.ago).destroy_all
  end

  # PII fields that must be scrubbed from version history, keyed by model.
  PATIENT_PII_FIELDS = %w[
    name primary_phone other_phone other_contact
    other_contact_relationship city state county zipcode
  ].freeze

  SCRUB_TARGETS = {
    'Patient' => PATIENT_PII_FIELDS,
    'Note' => %w[full_text],
    'PracticalSupport' => %w[attachment_url]
  }.freeze

  # Remove PII from all existing version records for tracked models.
  # This permanently deletes PII keys from the object and object_changes
  # JSON columns, preserving the audit trail without leaking sensitive data.
  def self.scrub_patient_pii
    scrubbed = 0
    SCRUB_TARGETS.each do |model_name, pii_fields|
      PaperTrailVersion.where(item_type: model_name).find_each do |version|
        changed = false

        if version.object.present?
          pii_fields.each do |field|
            if version.object.key?(field)
              version.object.delete(field)
              changed = true
            end
          end
        end

        if version.object_changes.present?
          pii_fields.each do |field|
            if version.object_changes.key?(field)
              version.object_changes.delete(field)
              changed = true
            end
          end
        end

        if changed
          version.save!
          scrubbed += 1
        end
      end
    end
    scrubbed
  end

  private

  def format_fieldchange(key, value)
    shaped_value = if value.blank?
                     '(empty)'
                   elsif DATE_FIELDS.include? key
                     year, month, day = value.split('-')
                     "#{month.rjust(2, '0')}/#{day.rjust(2, '0')}/#{year}"
                   elsif TIME_FIELDS.include? key
                     year, month, day = value.gsub(/T.*/, '').split('-')
                     "#{month.rjust(2, '0')}/#{day.rjust(2, '0')}/#{year}"
                   elsif value.is_a? Array # special circumstances, for example
                     value.reject(&:blank?).join(', ')
                   elsif key == 'clinic_id'
                     Clinic.find(value).name
                   elsif key == 'pledge_generated_by_id'
                     ::User.find(value).name # Use the User model instead of the Userstamp namespace
                   else
                     value
                   end
    shaped_value
  end
end
