require_relative '../lib/api_clients/twilio_verify_client'

# Controls steps for logging in a user with two factor authentication.
class MultiFactorAuthenticationController < ApplicationController
  include Wicked::Wizard

  steps :factor_select, :verification

  skip_before_action :authenticate_user!, :confirm_user_not_disabled!

  def show
    case step
    when :factor_select
      user = User.find_by(id: session.dig(:mfa, :user_id))
      return redirect_to new_user_session_path, error: 'Authentication error' unless user

      @auth_factors = user.auth_factors.select(&:enabled?)
    when :verification
      @auth_factor = AuthFactor.find(session[:auth_factor_id])
    end
    render_wizard
  end

  def update
    @client = TwilioVerifyClient.new
    case step
    when :factor_select
      send_verification_code
    when :verification
      verify_code
    end
  end

  private

  def send_verification_code
    # Needs the list of auth factors to populate the dropdown in the
    # case of an error where we have to re-render factor select.
    user = User.find(session[:mfa][:user_id])
    @auth_factors = user.auth_factors.select(&:enabled?)

    auth_factor_id = mfa_params[:auth_factor_id]
    auth_factor = AuthFactor.find(auth_factor_id)

    # Populate session with the selected auth factor id so we know
    # which factor to verify in the next step.
    session[:auth_factor_id] = auth_factor_id

    begin
      @client.send_sms_verification_code(auth_factor.phone)

      # Not really skipping a step. This just ensures we go to the next step when
      # we call render_wizard below instead of staying at the current step.
      skip_step
    rescue StandardError => e
      flash.now[:alert] = "There was a problem sending the verification code: #{e.message}"
    end
    render_wizard
  end

  def verify_code
    @auth_factor = AuthFactor.find(session[:auth_factor_id])
    begin
      status = @client.check_sms_verification_code(@auth_factor.phone, mfa_params[:code])
    rescue StandardError => e
      flash.now[:alert] = "There was a problem checking the verification code: #{e.message}"
      return render_wizard
    end

    unless status == 'approved'
      flash.now[:alert] = 'invalid code'
      return render_wizard
    end

    sign_in_user
  end

  def mfa_params
    permitted_attributes = case step
                           when :factor_select
                             [:auth_factor_id]
                           when :verification
                             [:code]
                           end
    params.permit(permitted_attributes)
  end

  def sign_in_user
    user = User.find(session[:mfa][:user_id])

    sign_in(:user, user)

    user.remember_me! if session[:mfa][:remember_me]

    flash[:notice] = 'Login with MFA successful!'
    session.delete(:auth_factor_id)
    session.delete(:mfa)

    redirect = stored_location_for(user) || root_url
    redirect_to redirect
  end
end
