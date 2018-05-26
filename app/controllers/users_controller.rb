# Additional user methods in parallel with Devise -- all pertaining to call list
class UsersController < ApplicationController
  before_action :confirm_admin_user, only: [:new, :index, :update,
                                            :change_role_to_admin,
                                            :change_role_to_data_volunteer,
                                            :change_role_to_cm,
                                            :toggle_disabled]
  before_action :confirm_admin_user_async, only: [:search]
  before_action :find_user, only: [:update, :edit, :change_role_to_admin,
                                   :change_role_to_data_volunteer,
                                   :change_role_to_cm, :toggle_disabled]

  rescue_from Mongoid::Errors::DocumentNotFound, with: -> { head :not_found }
  rescue_from Exceptions::UnauthorizedError, with: -> { head :unauthorized }

  def index
    @users = User.all
  end

  def edit; end

  def search
    @results = if params[:search].empty?
                 User.all
               else
                 User.search params[:search]
               end
    respond_to { |format| format.js }
  end

  def new
    @user = User.new
    session[:return_to] ||= request.referer
  end

  def update
    if @user.update_attributes(user_params)
      flash[:notice] = 'Successfully updated user details'
      redirect_to users_path
    else
      error_content = @user.errors.full_messages.to_sentence
      flash[:alert] = "Error saving user details - #{error_content}" unless flash[:alert]
      render 'edit'
    end
  end

  def create
    raise Exceptions::UnauthorizedError unless current_user.admin?
    @user = User.new(user_params)
    hex = SecureRandom.urlsafe_base64
    @user.password, @user.password_confirmation = hex
    if @user.save
      flash[:notice] = 'User created!'
      redirect_to users_path
    else
      render 'new'
    end
  end

  def change_role_to_admin
    @user.update role: 'admin'
    render 'edit'
  end

  def change_role_to_data_volunteer
    @user.update role: 'data_volunteer' if user_not_demoting_themself?(@user)
    render 'edit'
  end

  def change_role_to_cm
    @user.update role: 'cm' if user_not_demoting_themself?(@user)
    render 'edit'
  end

  def toggle_disabled
    if @user == current_user
      flash[:alert] = "You can't lock your own account. Ask another admin."
    else
      @user.toggle_disabled_by_fund
      verb = @user.disabled_by_fund? ? 'Locked' : 'Unlocked'
      flash[:notice] = "#{verb} #{@user.name}'s account."
    end
    redirect_to users_path
  end

  # # TODO find_user tweaking.
  # def reset_password
  #   # @user = User.find(params[:user_id])

  #   # TODO doesn't work in dev
  #   @user.send_reset_password_instructions

  #   flash[:notice] = "Successfully sent password reset instructions to #{@user.email}"
  #   redirect_to edit_user_path @user
  # end

  private

  def find_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end

  def user_not_demoting_themself?(user)
    if user.id == current_user.id && current_user.role == 'admin'
      flash[:alert] = 'For safety reasons, you are not allowed to change ' \
                      'your role from an admin to a not-admin. Ask another '\
                      'admin to demote you.'
      return false
    end
    true
  end
end
