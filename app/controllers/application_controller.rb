require 'SecureRandom'

# Sets a few devise configs and security measures
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery prepend: true, with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :prevent_caching_via_headers, unless: :devise_controller?
  before_action :authenticate_user!
  before_action :csp_headers

  # whitelists attributes in devise
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  private

  # Prevents app from caching pages as a security measure
  def prevent_caching_via_headers
    response.headers['Cache-Control'] = 'no-cache, no-store'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end

  # Add CSP
  def csp_headers
    nonce = SecureRandom.uuid
    response.headers['Content-Security-Policy-Report-Only'] =
      "default-src 'self'; " \
      "script-src 'self' 'nonce-#{nonce}' 'unsafe-eval'; " \
      "font-src 'self' fonts.gstatic.com; " \
      "style-src 'self' 'unsafe-inline'; " \
      'object-src; ' \
      "report-uri https://#{ENV['CSP_VIOLATION_URI']}/csp/reportOnly"
  end

  def confirm_admin_user
    redirect_to root_url unless current_user.admin?
  end

  def confirm_user_has_data_access
    redirect_to root_url unless (current_user.admin? || current_user.data_volunteer?)
  end
end
