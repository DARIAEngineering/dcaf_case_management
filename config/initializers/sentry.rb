# # Configure sentry
# Sentry.init do |config|
#   config.dsn = ENV['SENTRY_DSN']
#   config.send_default_pii = true

#   # Roughly reimplement sanitize_fields; see https://github.com/getsentry/sentry-ruby/issues/1140#issuecomment-788089679
#   filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
#   config.before_send = lambda do |event, hint|
#     filter.filter(event.to_hash)
#   end
# end
