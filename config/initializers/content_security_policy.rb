# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.object_src  :none
  policy.font_src    :self, :https, :data, 'fonts.gstatic.com'
  policy.connect_src :self
  policy.script_src  :self, :https
  policy.style_src   :self, :https
  # Specify URI for violation reports
  policy.report_uri  "https://#{ENV['CSP_VIOLATION_URI']}/csp/reportOnly"

  # Maybe not needed anymore?
  # # If ASSET_SITE_URL is set, allow that too
  # policy.script_src  :self, :https, "https://#{ENV['ASSET_SITE_URL']}", :unsafe_eval    if ENV['ASSET_SITE_URL'].present?
  # policy.style_src   :self, "https://#{ENV['ASSET_SITE_URL']}", :unsafe_inline  if ENV['ASSET_SITE_URL'].present?

  # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w(script-src style-src)

  # Automatically add `nonce` to `javascript_tag`, `javascript_include_tag`, and `stylesheet_link_tag`
  # if the corresponding directives are specified in `content_security_policy_nonce_directives`.
  # config.content_security_policy_nonce_auto = true

  # Report violations without enforcing the policy.
  # config.content_security_policy_report_only = true
end
