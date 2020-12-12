# Object representing relevant actions taken by a case  manager
class MongoEvent
  include Mongoid::Document
  include Mongoid::Timestamps
  extend Enumerize

  EVENT_TYPES = [
    'Reached patient',
    "Couldn't reach patient",
    'Left voicemail',
    'Pledged',
    'Unknown action'
  ].freeze

  # Fields
  field :cm_name, type: String
  enumerize :event_type,
            in:      EVENT_TYPES.map(&:to_sym),
            default: 'Unknown action'.to_sym
  # See config/initializers/env_var_contants.rb
  enumerize :line, in: LINES, default: LINES[0]
  field :patient_name, type: String
  field :patient_id, type: String
  field :pledge_amount, type: Integer

  # Indices
  index(created_at: 1)

  # Validations
  validates :event_type, inclusion: { in: EVENT_TYPES }
  validates :cm_name, :patient_name, :patient_id, :line, presence: true
  validates :pledge_amount, presence: true, if: :pledged_type?

  def icon
    case event_type
    when 'Pledged'
      'thumbs-up'
    when 'Reached patient'
      'comment'
    else
      'phone-alt'
    end
  end

  # remove spaces and punctuation. A sin method because we did this as strs not syms.
  def underscored_type
    event_type.gsub(' ', '_').gsub(/\W/, '').downcase
  end

  # Clean events older than three weeks
  def self.destroy_old_events
    Event.where(:created_at.lte => 3.weeks.ago)
         .destroy_all
  end

  private

  def pledged_type?
    event_type == 'Pledged'
  end
end
