# Sets a few devise configs and security measures
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :prevent_caching_via_headers, unless: :devise_controller?
  before_action :authenticate_user!
  before_action :security_headers

  # whitelists attributes in devise
  def configure_permitted_parameters
    [:name].each do |sym|
      devise_parameter_sanitizer.for(:sign_up) << sym
      devise_parameter_sanitizer.for(:account_update) << sym
    end
  end

  private

  # Prevents app from caching pages as a security measure
  def prevent_caching_via_headers
    response.headers['Cache-Control'] = 'no-cache, no-store'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end

  # Add CSP
  def security_headers
    response.headers['Content-Security-Policy-Report-Only'] = "default-src 'self'; script-src 'self' www.google-analytics.com 'sha256-1kYydMhZjhS1eCkHYjBthAOfULylJjbss3YE6S2CGLc='; font-src 'self' fonts.gstatic.com; style-src 'self' 'sha256-wkY2X5hecQzbhnFCqvTpwrUJ1f4X8LH5WFjYUzv1wmU='; object-src;"
  end
end
