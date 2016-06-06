class DashboardsController < ApplicationController
  def index
    @urgent_pregnancies = Pregnancy.where(urgent_flag: true)
  end

  def search
    patients = Patient.search params[:search]
    @results = []
    patients.each do |patient|
      @results << patient.pregnancies.most_recent
    end
    @patient = Patient.new
    @pregnancy = @patient.pregnancies.new
    @today = Time.zone.today.to_date

    respond_to { |format| format.js }
  end
end
