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

  store_in collection: 'events'

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
end
