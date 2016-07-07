class UsersController < ApplicationController
  before_action :retrieve_pregnancies
  rescue_from Mongoid::Errors::DocumentNotFound, with: -> { head :bad_request }

  def add_pregnancy
    current_user.add_pregnancy @pregnancy
    respond_to do |format|
      format.js { render template: 'users/refresh_pregnancies', layout: false }
    end
  end

  def remove_pregnancy
    current_user.remove_pregnancy @pregnancy
    respond_to do |format|
      format.js { render template: 'users/refresh_pregnancies', layout: false }
    end
  end

  private

  def retrieve_pregnancies
    @pregnancy = Pregnancy.find params[:id]
    @urgent_pregnancies = Pregnancy.where(urgent_flag: true)
  end
end
