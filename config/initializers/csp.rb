SecureHeaders::Configuration.default do |config|  
  config.csp = {
    preserve_schemes: true, # default: false.
    default_src: %w('self'),
    script_src: %w('self' 'unsafe-eval'),
    font_src: %w('self' fonts.gstatic.com),
    connect_src: %w('self'),
    style_src: %w('self' 'unsafe-inline'),
    report_uri: ["https://#{ENV['CSP_VIOLATION_URI']}/csp/reportOnly"]
  }
end 
