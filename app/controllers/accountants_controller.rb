# Controller pertaining to accountant functions, usually fulfillments.
class AccountantsController < ApplicationController
  before_action :confirm_admin_user

  def index
    @patients = Patient.where('fulfillment.fulfilled' => true)
    @patients = Kaminari.paginate_array(@patients).page(params[:page]).per(25)
  end

  def search
    unless params[:search] == ''
      @results = Patient.where('fulfillment.fulfilled' => true).search(params[:search])
    else
      @results = Patient.where('fulfillment.fulfilled' => true)
    end
    respond_to { |format| format.js }
  end

  def edit_fulfillment
    @patient = Patient.find(params[:patient])
    respond_to { |format| format.js }
  end
end
