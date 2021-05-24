# Extensions to base class of PaperTrail.
class PaperTrailVersion < PaperTrail::Version
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
    mongo_id
    created_at
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
             .reduce({}) do |acc, x|
               key = x[0]
               acc.merge({ key => { original: format_fieldchange(key, x[1][0]),
                                    modified: format_fieldchange(key, x[1][1]) }})
             end
  end

  private

  def marked_urgent?
    object_changes['marked_urgent']&.last == true
  end

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
