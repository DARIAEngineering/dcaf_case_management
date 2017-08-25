# Allows models to have changed logged on create
module EventLoggable
  extend ActiveSupport::Concern

  included do
    after_create -> { log_event(event_params) }
  end

  def log_event(params = {})
    Event.create!(params)
  end
end
