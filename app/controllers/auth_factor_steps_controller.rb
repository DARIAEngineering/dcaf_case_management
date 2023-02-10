# Controls steps for registering a new authentication factor.
class AuthFactorStepsController < ApplicationController
  include Wicked::Wizard

  steps(*AuthFactor.form_steps)

  def show
    @auth_factor = AuthFactor.find(session[:auth_factor_id])
    render_wizard
  end

  def update
    @auth_factor = AuthFactor.find(session[:auth_factor_id])
    @client = TwilioVerifyClient.new
    case step
    when :registration
      register
    when :verification
      verify
    end
  end

  def finish_wizard_path
    session[:auth_factor_id] = nil
    edit_user_registration_path
  end

  private

  def register
    @auth_factor.assign_attributes(auth_factor_params)
    return render_wizard unless @auth_factor.valid?

    begin
      @client.send_sms_verification_code(auth_factor_params[:phone])
      return render_wizard @auth_factor
    rescue StandardError => e
      flash.now[:alert] = t('multi_factor.sending_sms_code_failed', error: e.message)
    end
    render_wizard
  end

  def verify
    begin
      status = @client.check_sms_verification_code(@auth_factor.phone, auth_factor_params[:code])
    rescue StandardError => e
      flash.now[:alert] = t('multi_factor.checking_sms_code_failed', error: e.message)
      return render_wizard
    end

    unless status == 'approved'
      flash.now[:alert] = t('multi_factor.code_invalid')
      return render_wizard
    end

    @auth_factor.enabled = true
    @auth_factor.registration_complete = true
    render_wizard @auth_factor
  end

  def auth_factor_params
    permitted_attributes = case step
                           when :registration
                             [:phone, :name]
                           when :verification
                             [:code]
                           end
    params.require(:auth_factor).permit(permitted_attributes).merge(current_form_step: step.to_sym)
  end
end
