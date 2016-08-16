class UsersController < ApplicationController
  before_action :retrieve_pregnancies, only: [:add_pregnancy, :remove_pregnancy]
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

  def reorder_call_list
    # TODO: fail if anything is not a BSON id
    current_user.reorder_call_list params[:order] # TODO: adjust to payload
    # respond_to { |format| format.js }
    head :ok
  end

  private

  def retrieve_pregnancies
    @pregnancy = Pregnancy.find params[:id]
    @urgent_pregnancies = Pregnancy.where(urgent_flag: true)
  end
end
