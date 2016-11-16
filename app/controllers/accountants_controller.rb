class AccountantsController < ApplicationController
  def index
  end

  def search
    @results = Patient.search params[:search]

    respond_to { |format| format.js }
  end

end
