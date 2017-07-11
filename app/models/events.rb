# Object representing relevant actions taken by a case  manager
class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::History::Trackable
  include Mongoid::Userstamp
  # Fields
  field :event_type, type: String
  field :cm_name, type: String
  field :patient_name, type: String
  field :patient_id, type: Integer

  # Validations
  event_types = [
    'Called',
    'Called but did not reach',
    'Left a voicemail for',
    'Pledged'
  ]
  validates :event_type, inclusion: { in: event_types }
  validates :cm_name, :patient_name, :patient_id, presence: true
end
