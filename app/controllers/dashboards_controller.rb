class DashboardsController < ApplicationController
  def index
    @patient = Patient.new
    @pregnancies = @patient.pregnancies.build
    @urgent_pregnancies = Pregnancy.where(urgent_flag: true)
  end

  def search
    patients = Patient.search params[:search]
    @results = []
    patients.each do |patient|
      @results << patient.pregnancies.most_recent
    end

    respond_to { |format| format.js }
  end
end
