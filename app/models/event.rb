# Object representing relevant actions taken by a case  manager
class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  extend Enumerize

  # Fields
  field :cm_name, type: String
  enumerize :event_type, in: [event_types], default: :not_specified
  enumerize :line, in: LINES, default: LINES[0] # See config/initializers/env_vars.rb
  field :patient_name, type: String
  field :patient_id, type: String

  # Validations
  event_types = [
    'Reached patient',
    "Couldn't reach patient",
    'Left voicemail',
    'Pledged'
  ]
  validates :event_type, inclusion: { in: event_types }
  validates :cm_name, :patient_name, :patient_id, presence: true
end
