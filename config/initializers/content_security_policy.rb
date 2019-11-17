# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.object_src  :none
  policy.font_src    :self, 'fonts.gstatic.com'
  policy.connect_src :self
  policy.script_src  :self, :unsafe_eval
  policy.style_src   :self, :unsafe_inline

  # Specify URI for violation reports
  policy.report_uri  "https://#{ENV['CSP_VIOLATION_URI']}/csp/reportOnly"

  # If you are using webpack-dev-server then specify webpack-dev-server host
  if Rails.env.development?
    policy.connect_src :self, "http://localhost:3035", "ws://localhost:3035"
  end
end

# If you are using UJS then enable automatic nonce generation
Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }
