class DashboardsController < ApplicationController
  def index
  @urgent_pregnancies = Pregnancy.where(urgent_flag: true)
  end


  def search
    patients = Patient.search params[:search]
    @results = []
<<<<<<< HEAD
    patients.each do |patient|
    @results = patient.pregnancies.most_recent
  end
    @patient = Patient.new
    @pregnancy = @patient.pregnancies.new
    @today = Time.zone.today.to_date
    respond_to { |format| format.js }
  end
end
=======
    patients.each { |patient| @results << patient.pregnancies.most_recent }

    patient = Patient.new
    @pregnancy = patient.pregnancies.new
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
>>>>>>> upstream/master
