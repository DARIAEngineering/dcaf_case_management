# Additional user methods in parallel with Devise -- all pertaining to call list
class UsersController < ApplicationController
  before_action :confirm_admin_user, only: [:new, :index, :update, :edit,
                                            :change_role_to_admin,
                                            :change_role_to_data_volunteer,
                                            :change_role_to_cm,
                                            :toggle_disabled]
  before_action :confirm_admin_user_async, only: [:search]
  before_action :find_user, only: [:update, :edit, :change_role_to_admin,
                                   :change_role_to_data_volunteer,
                                   :change_role_to_cm, :toggle_disabled]

  rescue_from ActiveRecord::RecordNotFound, with: -> { head :not_found }
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
    session[:return_to] ||= users_path
  end

  def update
    # i18n-tasks-use t('mongoid.attributes.user.current_password')
    # i18n-tasks-use t('mongoid.attributes.user.name')
    # i18n-tasks-use t('mongoid.attributes.user.password')
    # i18n-tasks-use t('mongoid.attributes.user.password_confirmation')
    # i18n-tasks-use t('mongoid.attributes.user.role')
    if @user.update user_params
      flash[:notice] = t('flash.user_update_success')
      redirect_to users_path
    else
      error_content = @user.errors.full_messages.to_sentence
      flash[:alert] = t('flash.user_update_error', error: error_content) unless flash[:alert]
      render 'edit'
    end
  end

  def create
    raise Exceptions::UnauthorizedError unless current_user.admin?
    @user = User.new(user_params)
    hex = SecureRandom.urlsafe_base64
    @user.password, @user.password_confirmation = hex
    if @user.save
      flash[:notice] = t('flash.user_created')
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
      flash[:alert] = t('flash.cant_lock_own_account')
    else
      @user.toggle_disabled_by_fund
      verb = @user.disabled_by_fund? ? t('flash.locked') : t('flash.unlocked')
      flash[:notice] = t('flash.action_on_account', verb: verb, name: @user.name)
    end
    redirect_to users_path
  end

  private

  def find_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end

  def user_not_demoting_themself?(user)
    if user.id == current_user.id && current_user.role == 'admin'
      flash[:alert] = t('flash.demote_own_account_warn')
      return false
    end
    true
  end
end
