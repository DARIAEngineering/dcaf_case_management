# Configure sentry
Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  # TODO - sanitize_fields is removed - what's our next step?
  #config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end
