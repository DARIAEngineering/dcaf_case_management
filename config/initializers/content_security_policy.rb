Rails.application.config.content_security_policy do |policy|
  policy.default_src :self
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.object_src  :none
  policy.font_src    :self, 'fonts.gstatic.com'
  policy.connect_src :self
  policy.script_src  :self, :unsafe_eval, :unsafe_inline
  policy.style_src   :self, :unsafe_inline
  policy.report_uri  "https://#{ENV['CSP_VIOLATION_URI']}/csp/reportOnly"

  if Rails.env.development?
    policy.connect_src :self, "http://localhost:3035", "ws://localhost:3035"
  end
end

# Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }
