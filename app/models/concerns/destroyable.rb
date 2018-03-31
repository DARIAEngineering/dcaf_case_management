# Methods relating to cleanup after a patient object is destroyed as a duplicate
module Destroyable
  extend ActiveSupport::Concern

  def destroy_associated_events
    Event.where(patient_id: id.to_s).destroy_all
  end
end
