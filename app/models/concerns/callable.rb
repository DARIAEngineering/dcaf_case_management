# Methods relating to calls or contacts
module Callable
  extend ActiveSupport::Concern

  def recent_calls
    calls.includes(:created_by).order('created_at DESC').limit(10)
  end

  def old_calls
    calls.includes(:created_by).order('created_at DESC').offset(10)
  end

  class_methods do
    def contacted_since(datetime)
      patients_reached = []
      all.each do |patient|
        calls = patient.calls.select { |call| call.status == 'Reached patient' &&
                                              call.created_at >= datetime }
        patients_reached << patient if calls.present?
      end

      # Should we use this or first call?
      first_contact = patients_reached.select { |patient| patient.initial_call_date >= datetime }

      # hard coding in first_contacts and pledges_sent for now
      { since: datetime, contacts: patients_reached.length,
        first_contacts: first_contact.length, pledges_sent: 20 }
    end
  end
end
