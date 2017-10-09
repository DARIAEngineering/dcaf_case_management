# Controller pertaining to accountant functions, usually fulfillments.
class AccountantsController < ApplicationController
  def index
    @patients = Patient.where('fulfillment.fulfilled' => true)
  end

  def search
    @results = Patient.search params[:search]

    respond_to { |format| format.js }
  end
end
