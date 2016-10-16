# Additional user methods in parallel with Devise -- all pertaining to call list
class UsersController < ApplicationController
  before_action :retrieve_patients, only: [:add_patient, :remove_patient]
  rescue_from Mongoid::Errors::DocumentNotFound, with: -> { head :bad_request }

  def create
    raise 'Permission Denied' unless current_user.admin?
    @user = User.new(user_params)
    if @user.save
      flash[:success] = 'User created!'
      redirect_to session.delete(:return_to)
    else
      # if validation errors, render creation page with error msgs
      render 'new'
    end
  end

  def new
    unless current_user.admin?
      redirect_to root_path
      return
    end
    @user = User.new
    session[:return_to] ||= request.referer
  end

  def add_patient
    current_user.add_patient @patient
    respond_to do |format|
      format.js { render template: 'users/refresh_patients', layout: false }
    end
  end

  def remove_patient
    current_user.remove_patient @patient
    respond_to do |format|
      format.js { render template: 'users/refresh_patients', layout: false }
    end
  end

  def reorder_call_list
    # TODO: fail if anything is not a BSON id
    current_user.reorder_call_list params[:order] # TODO: adjust to payload
    # respond_to { |format| format.js }
    head :ok
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def retrieve_patients
    @patient = Patient.find params[:id]
    @urgent_patient = Patient.where(urgent_flag: true)
  end
end
