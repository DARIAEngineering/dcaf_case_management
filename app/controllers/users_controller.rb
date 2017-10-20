# Additional user methods in parallel with Devise -- all pertaining to call list
class UsersController < ApplicationController
  before_action :retrieve_patients, only: [:add_patient, :remove_patient]
  before_action :confirm_admin_user, only: [:new, :index, :update]
  before_action :find_user, only: [:update, :edit, :destroy, :reset_password, :clear_call_list]

  rescue_from Mongoid::Errors::DocumentNotFound, with: -> { head :bad_request }

  def index
    @users = User.all
  end

  def edit
  end

  def search # TODO needs more rigorous testing
    if params[:search].empty?
      @results = User.all
    else
      @results = User.search params[:search]
    end
    respond_to { |format| format.js }
  end

  def toggle_lock
    # @user = User.find(params[:user_id])
    # if @user == current_user
    #   redirect_to edit_user_path @user
    # else
    #   if @user.access_locked?
    #     flash[:notice] = 'Successfully unlocked ' + @user.email
    #     @user.unlock_access!
    #   else
    #     flash[:notice] = 'Successfully locked ' + @user.email
    #     @user.lock_access!
    #   end
    #   redirect_to edit_user_path @user
    # end
  end

  # TODO find_user tweaking.
  def reset_password
    # @user = User.find(params[:user_id])

    # TODO doesn't work in dev
    @user.send_reset_password_instructions

    flash[:notice] = "Successfully sent password reset instructions to #{@user.email}"
    redirect_to edit_user_path @user
  end

  def update # TODO needs more rigorous testing
    if @user.update_attributes user_params
      flash[:notice] = 'Successfully updated user details'
      redirect_to users_path
    else
      flash[:alert] = 'Error saving user details'
      render 'edit'
    end
  end

  def create # TODO needs more rigorous testing
    raise('Permission Denied') unless current_user.admin?
    @user = User.new(user_params)
    hex = SecureRandom.urlsafe_base64
    @user.password, @user.password_confirmation = hex
    if @user.save
      flash[:notice] = 'User created!'
      redirect_to session.delete(:return_to)
    else
      # TODO if validation errors, render creation page with error msgs
      render 'new'
    end
  end

  def new # TODO needs more rigorous testing
    @user = User.new
    session[:return_to] ||= request.referer
  end

  def add_patient
    current_user.add_patient @patient
    flash.now[:notice] = "Successfully added call"
    respond_to do |format|
      format.js { render template: 'users/refresh_patients' }
    end
  end

  def remove_patient
    current_user.remove_patient @patient
    flash.now[:notice] = "Successfully removed call"
    respond_to do |format|
      format.js { render template: 'users/refresh_patients'}
    end
  end

  def clear_call_list
    current_user.patients.clear
    flash.now[:notice] = "Successfully removed all calls"
    respond_to do |format|
      format.js { render template: 'users/refresh_patients' }
    end
  end

  def reorder_call_list
    # TODO: fail if anything is not a BSON id
    current_user.reorder_call_list params[:order] # TODO: adjust to payload
    # respond_to { |format| format.js }
    head :ok
  end

  private

  def find_user # TODO needs more rigorous testing
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end

  def retrieve_patients
    @patient = Patient.find params[:id]
    @urgent_patient = Patient.where(urgent_flag: true)
  end
end
