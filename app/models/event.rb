# Object representing relevant actions taken by a case  manager
class Event < ApplicationRecord
  # Validations
  validates :event_type, inclusion: { in: EVENT_TYPES }
  validates :cm_name, :patient_name, :patient_id, :line, presence: true
  validates :pledge_amount, presence: true, if: :pledged_type?

  # Enum values
  enum event_type: {
    'Reached patient': 0,
    "Couldn't reach patient": 1,
    'Left voicemail': 2,
    'Pledged': 3,
    'Unknown action': 4,
  }

  enum line: LINES.map { |x| [x, LINES.index(x)] }.to_h

  # Methods
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
