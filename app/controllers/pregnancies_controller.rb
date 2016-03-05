class PregnanciesController < ApplicationController
  def index
  	@patient = Patient.new
    @pregnancies = @patient.pregnancies.build
    @urgent_pregnancies = Pregnancy.where(urgent_flag: true)
  end

  def search
    name_match = Patient.where(name: params[:search])
    primary_match = Patient.where(primary_phone: params[:search])
    secondary_match = Patient.where(secondary_phone: params[:search])
    patients = name_match | primary_match | secondary_match
    @results = []
    patients.each do |patient|
      @results << patient.pregnancies.most_recent
    end

    respond_to do |format|
      format.js
    end
  end

  def edit
    # TODO change to pregnancy
    # @case = Case.find(params[:id]) #.includes(:patient)
    @pregnancy = Pregnancy.find(params[:id])
    # @patient = @case.patient
  end

  def update
  end

end
