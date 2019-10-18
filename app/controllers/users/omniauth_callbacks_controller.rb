# Controller allowing authentication via google oauth.
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  rescue_from Mongoid::Errors::DocumentNotFound,
              with: -> { redirect_to root_path }

  # i18n-tasks-use  t('devise.sessions.failure.user.unauthenticated')
  # i18n-tasks-use t('devise.sessions.user.signed_in')
  # i18n-tasks-use t('devise.passwords.send_paranoid_instructions')
  #
  def google_oauth2
    response.headers['Content-Type'] = 'text/html'
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      log_in_user_via_google
    else
      reject_login
    end
  end

  private

  def log_in_user_via_google
    flash[:notice] = I18n.t 'devise.omniauth_callbacks.success',
                            kind: 'Google'
    sign_in @user, event: :authentication
    redirect_to root_path
  end

  def reject_login
    session['devise.google_data'] = request.env['omniauth.auth'].except(:extra)
    redirect_to root_path
  end
end
