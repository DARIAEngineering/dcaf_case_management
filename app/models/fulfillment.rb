# Indicator that a pledge by the primary fund was cashed in,
# which in turn indicates that the patient used our pledged money.
class Fulfillment
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

  # Relationships
  embedded_in :patient

  field :fulfilled, type: Boolean
  field :procedure_date, type: Date
  field :gestation_at_procedure, type: String
  field :procedure_cost, type: Integer
  field :check_number, type: String
  field :date_of_check, type: Date

  # Validations
  validates :created_by_id,
            presence: true

#  validate :archived_state, if: self.patient.archived?

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'

  FULFILLMENT_ARCHIVE_REFERENCE = {
    'check_number'           => :shred,
    '_id'                    => :keep,
    'created_by_id'          => :keep,
    'updated_at'             => :keep,
    'created_at'             => :keep,
    'version'                => :keep,
    'fulfilled'              => :keep,
    'procedure_date'         => :keep,
    'gestation_at_procedure' => :keep,
    'procedure_cost'         => :keep,
    'date_of_check'          => :keep,
  }.freeze

  # still not DRY
  def archive!
    self.attributes.keys.each do |field|
      if FULFILLMENT_ARCHIVE_REFERENCE.has_key?(field)
        action = FULFILLMENT_ARCHIVE_REFERENCE[field]
        if action == :keep
          #puts "Found a keep! (#{field})"
          next
        elsif action == :shred
          #puts "Found a #{action} for field #{field}!"
          self[field] = nil
        else
          logger.warn "Func '#{action}' for fulfillment field '#{field}' not found. Shredding"
          #puts "Func '#{action}' for field '#{field}' not found. Shredding"
          self[field] = nil
        end
      else
        logger.warn "Found unaccounted for key '#{field}' on fulfillment when archiving. " \
                    "Shredding the content of this field. Please add proper " \
                    "handling for the field in the archive concern"
        self[field] = nil
      end
    end
    self.save
  end

  # validator
  def archived_state
    if check_number.present? && ! check_number.nil?
      errors.add(:check_number, "should be nil for archived patients")
    end
  end

end
