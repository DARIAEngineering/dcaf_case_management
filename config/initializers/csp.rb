popover_sha = "'sha256-1kYydMhZjhS1eCkHYjBthAOfULylJjbss3YE6S2CGLc='"

SecureHeaders::Configuration.default do |config|
  config.csp = {
    preserve_schemes: true, # default: false.
    default_src: %w('self'),
    script_src: ["'self'", "'unsafe-eval'", popover_sha],
    font_src: %w('self' fonts.gstatic.com),
    connect_src: %w('self'),
    style_src: %w('self' 'unsafe-inline'),
    report_uri: ["https://#{ENV['CSP_VIOLATION_URI']}/csp/reportOnly"]
  }

  # From output of rails webpack:install
  # You need to allow webpack-dev-server host as allowed origin for connect-src.
  # This can be done in Rails 5.2+ for development environment in the CSP initializer
  # config/initializers/content_security_policy.rb with a snippet like this:
  # policy.connect_src :self, :https, "http://localhost:3035", "ws://localhost:3035" if Rails.env.development?

  if Rails.env.development?
    config.csp[:connect_src].concat ["http://localhost:3035", "ws://localhost:3035"]
  end
end
