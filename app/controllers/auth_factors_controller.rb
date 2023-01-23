class AuthFactorsController < ApplicationController
  # Initializes an auth_factor then hands off to the AuthFactorStepsController
  # which handles the multi-step registration process.
  def new
    auth_factor_id = session[:auth_factor_id]
    unless auth_factor_id
      @auth_factor = AuthFactor.new
      @auth_factor.user = current_user
      @auth_factor.channel = 'sms'
      @auth_factor.save! validate: false
      session[:auth_factor_id] = @auth_factor.id
    end
    redirect_to build_auth_factor_path(AuthFactor.form_steps.first)
  end

  def destroy
    @auth_factor = AuthFactor.find params[:id]
    @auth_factor.destroy
    redirect_to edit_user_registration_path
  end
end
