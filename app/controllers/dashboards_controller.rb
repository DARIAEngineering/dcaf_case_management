class DashboardsController < ApplicationController
  def index
    @urgent_patients = Patient.urgent_patients
  end

  def search
    patients = Patient.search params[:search]
    @results = []
    patients.each { |patient| @results << patient }

    patient = Patient.new
    @today = Time.zone.today.to_date
    @phone = searched_for_phone?(params[:search]) ? params[:search] : ''
    @name = searched_for_name?(params[:search]) ? params[:search] : ''

    respond_to { |format| format.js }
  end

  private

  def searched_for_phone?(query)
    !/[a-z]/i.match query
  end

  def searched_for_name?(query)
    /[a-z]/i.match query
  end
end
