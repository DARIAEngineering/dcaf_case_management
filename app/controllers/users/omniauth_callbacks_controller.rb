# Controller allowing authentication via google oauth.
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  rescue_from Mongoid::Errors::DocumentNotFound,
              with: -> { redirect_to root_path }

  def google_oauth2
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      puts 'Getting here'
      log_in_user_via_google
    else
      puts 'login failing'
      reject_login
    end
  end

  private

  def log_in_user_via_google
    flash[:notice] = I18n.t 'devise.omniauth_callbacks.success',
                            kind: 'Google'
    sign_in_and_redirect @user, event: :authentication
  end

  def reject_login
    session['devise.google_data'] = request.env['omniauth.auth'].except(:extra)
    redirect_to root_path
  end
end
