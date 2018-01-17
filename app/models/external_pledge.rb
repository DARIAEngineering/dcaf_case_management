# Object representing money from organizations that aren't the fund or NAF.
# For primary fund pledges or NAF pledges, see the patient model.
class ExternalPledge
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp

  # Relationships
  embedded_in :patient

  default_scope -> { where(active: true) }
  scope :active, -> { where(active: true) }

  # Fields
  field :source, type: String # Name of outside organization or fund
  field :amount, type: Integer
  field :active, type: Boolean, default: true

  # Validations
  validates :created_by_id, :source, :amount, presence: true
  validates :source, uniqueness: { scope: :active }

  # History and auditing
  track_history on: fields.keys + [:updated_by_id],
                version_field: :version,
                track_create: true,
                track_update: true,
                track_destroy: true
  mongoid_userstamp user_model: 'User'

  PLEDGE_ARCHIVE_REFERENCE = {
    '_id'           => :keep,
    'active'        => :keep,
    'source'        => :keep,
    'amount'        => :keep,
    'created_at'    => :keep,
    'created_by_id' => :keep,
    'updated_at'    => :keep,
    'version'       => :keep,
  }.freeze

  # still not DRY
  def archive!
    self.attributes.keys.each do |field|
      if PLEDGE_ARCHIVE_REFERENCE.has_key?(field)
        action = PLEDGE_ARCHIVE_REFERENCE[field]
        if action == :keep
          #puts "Found a keep! (#{field})"
          next
        elsif action == :shred
          #puts "Found a #{action} for field #{field}!"
          self[field] = nil
        else
          logger.warn "Func '#{action}' for pledge field '#{field}' not found. Shredding"
          #puts "Func '#{action}' for field '#{field}' not found. Shredding"
          self[field] = nil
        end
      else
        logger.warn "Found unaccounted for key '#{field}' on Pledge when archiving. " \
                    "Shredding the content of this field. Please add proper " \
                    "handling for the field in the archive concern"
        self[field] = nil
      end
    end
    self.save
  end
end

