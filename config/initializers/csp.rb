gon_gem_sha = "'sha256-+PC+Kf6qxwFk9MeuRMDmsALBNWNX473zplWkiVYhJgY='"
popover_sha = "'sha256-1kYydMhZjhS1eCkHYjBthAOfULylJjbss3YE6S2CGLc='"

SecureHeaders::Configuration.default do |config|
  config.csp = {
    preserve_schemes: true, # default: false.
    default_src: %w('self'),
    script_src: ["'self'", "'unsafe-eval'", gon_gem_sha, popover_sha],
    font_src: %w('self' fonts.gstatic.com),
    connect_src: %w('self'),
    style_src: %w('self' 'unsafe-inline'),
    report_uri: ["https://#{ENV['CSP_VIOLATION_URI']}/csp/reportOnly"]
  }
end
