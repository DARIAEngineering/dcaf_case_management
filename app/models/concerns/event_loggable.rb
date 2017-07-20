module EventLoggable
  extend ActiveSupport::Concerns

  def log_event(params = {})
    Event.create!(params)
  end

  class_methods do
    after_create :log_event
  end
end
