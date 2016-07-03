class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :prevent_caching_via_headers

  # whitelists name attribute in devise
  def configure_permitted_parameters
    [:name].each do |sym|
      devise_parameter_sanitizer.for(:sign_up) << sym
      devise_parameter_sanitizer.for(:account_update) << sym
    end
  end

  private

  def prevent_caching_via_headers
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end
end
