# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  def new
    session.delete(:mfa)
    super
  end

  def create
    self.resource = warden.authenticate!(auth_options)

    if multi_factor_enabled?
      # preserve the stored location
      stored_location = stored_location_for(resource)

      # log out the user (this will also clear stored location)
      warden.logout

      # restore the stored location
      store_location_for(resource, stored_location)

      session[:mfa] = { user_id: resource.id }

      redirect_to multi_factor_authentication_path(:factor_select)
    else
      # continue without mfa
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    end
  end

  private

  def multi_factor_enabled?
    current_user.auth_factors.any?(&:enabled?)
  end
end
