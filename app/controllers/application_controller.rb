# Sets a few devise configs and security measures
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery prepend: true, with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :prevent_caching_via_headers
  before_action :authenticate_user!

  # whitelists attributes in devise
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update) do |user|
      user.permit :name, :current_password, :password, :password_confirmation
    end
  end

  private

  # Prevents app from caching pages as a security measure
  def prevent_caching_via_headers
    response.headers['Cache-Control'] = 'no-cache, no-store'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end

  def confirm_admin_user
    redirect_to root_url unless current_user.admin?
  end

  def confirm_admin_user_async
    head :unauthorized unless current_user.admin?
  end

  def redirect_unless_has_data_access
    redirect_to root_url unless current_user.allowed_data_access?
  end
end
