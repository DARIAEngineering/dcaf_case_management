# Controller pertaining to accountant functions, usually fulfillments.
class AccountantsController < ApplicationController
  before_action :confirm_admin_user

  def index
    fulfilled_pts = Patient.where('fulfillment.fulfilled' => true)
    @patients = Kaminari.paginate_array(fulfilled_pts)
                        .page(params[:page]).per(25)
  end

  def search
    @results = if params[:search] != ''
                 Patient.where('fulfillment.fulfilled' => true)
                        .search(params[:search])
               else
                 Patient.where('fulfillment.fulfilled' => true)
               end
    respond_to { |format| format.js }
  end

  def edit_fulfillment
    @patient = Patient.find(params[:patient])
    respond_to { |format| format.js }
  end
end
