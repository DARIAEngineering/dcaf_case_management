# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy do |policy|
  # policy.default_src :self
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.object_src  :none
  policy.font_src    :self, 'fonts.gstatic.com'
  policy.connect_src :self
  policy.script_src  :self, :unsafe_eval
  policy.style_src   :self, :unsafe_inline

  # Specify URI for violation reports
  policy.report_uri  "https://#{ENV['CSP_VIOLATION_URI']}/csp/reportOnly"

  # If ASSET_SITE_URL is set, allow that too
  policy.script_src  :self, "https://#{ENV['ASSET_SITE_URL']}", :unsafe_eval    if ENV['ASSET_SITE_URL'].present?
  policy.style_src   :self, "https://#{ENV['ASSET_SITE_URL']}", :unsafe_inline  if ENV['ASSET_SITE_URL'].present?
end

# If you are using UJS then enable automatic nonce generation
Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

# Set the nonce only to specific directives
Rails.application.config.content_security_policy_nonce_directives = %w(script-src)

# # Report CSP violations to a specified URI
# # For further information see the following documentation:
# # https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = false
# TEMPORARILY TRUE WHILE WE GET THE HANG OF JSBUNDLING
Rails.application.config.content_security_policy_report_only = true
