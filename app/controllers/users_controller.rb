class UsersController < ApplicationController
  before_action :get_user_and_pregnancies
  rescue_from Mongoid::Errors::DocumentNotFound, with: -> { head :bad_request }

  def add_pregnancy
    @user.pregnancies << @pregnancy
    respond_to do |format|
      format.js { render template: 'users/refresh_pregnancies.js.erb', layout: false }
    end
  end

  def remove_pregnancy
    @user.pregnancies.delete @pregnancy
    respond_to do |format|
      format.js { render template: 'users/refresh_pregnancies.js.erb', layout: false }
    end
  end

  private

  def get_user_and_pregnancies
    @pregnancy = Pregnancy.find params[:id]
    @user = User.find params[:user_id]
    @urgent_pregnancies = Pregnancy.where(urgent_flag: true)
  end
end
