# Sets a few devise configs and security measures
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery prepend: true, with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :prevent_caching_via_headers
  before_action :set_locale
  prepend_before_action :authenticate_user!
  prepend_before_action :confirm_user_not_disabled!, unless: :devise_controller?

  # whitelists attributes in devise
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update) do |user|
      user.permit :name, :current_password, :password, :password_confirmation
    end
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    return { :locale => I18n.locale } if I18n.locale != I18n.default_locale
    {}
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

  def confirm_data_access
    redirect_to root_path unless current_user.allowed_data_access?
  end

  def confirm_data_access_async
    head :unauthorized unless current_user.allowed_data_access?
  end

  def confirm_user_not_disabled!
    if current_user.disabled_by_fund?
      flash[:danger] = 'Account currently locked, check with your fund.'
      sign_out current_user
    end
  end
end
