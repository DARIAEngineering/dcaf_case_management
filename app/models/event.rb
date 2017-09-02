# Object representing relevant actions taken by a case  manager
class Event
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

  # Validations
  validates :event_type, inclusion: { in: EVENT_TYPES }
  validates :cm_name, :patient_name, :patient_id, :line, presence: true
  validates :pledge_amount, presence: true, if: :pledged_type?

  def glyphicon
    return 'thumbs-up' if event_type == 'Pledged'
    'earphone'
  end

  def event_text
    case event_type
    when 'Pledged'
      "sent a $#{pledge_amount} pledge for"
    when 'Left voicemail'
      'left a voicemail for'
    when "Couldn't reach patient"
      "called, but couldn't reach"
    when 'Reached patient'
      'reached'
    end
  end

  private

  def pledged_type?
    event_type == 'Pledged'
  end
end
