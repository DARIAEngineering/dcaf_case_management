# Object representing relevant actions taken by a case manager.
class Event < ApplicationRecord
  acts_as_tenant :fund

  # Enums
  enum event_type: {
    reached_patient: 0,
    couldnt_reach_patient: 1,
    left_voicemail: 2,
    pledged: 3,
    unknown_action: 4
  }
  # See config/initializers/_env_var_contants.rb
  enum line: LINES.map { |x| { x.to_sym => x.to_s } }.inject(&:merge)

  # Validations
  validates :event_type, :cm_name, :patient_name, :patient_id, :line, presence: true
  validates :pledge_amount, presence: true, if: :pledged?

  def icon
    case event_type
    when 'pledged'
      'thumbs-up'
    when 'reached_patient'
      'comment'
    else
      'phone-alt'
    end
  end

  # Clean events older than three weeks
  def self.destroy_old_events
    Event.where('created_at < ?', 3.weeks.ago)
         .destroy_all
  end
end
