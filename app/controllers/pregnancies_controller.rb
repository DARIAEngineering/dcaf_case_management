class PregnanciesController < ApplicationController
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

    respond_to do |format|
      format.js
    end
  end

  def edit
    @pregnancy = Pregnancy.find(params[:id])
  end

  def update
  end

  private

  def pregnancy_params
    params.require(:patient).permit(:name, :primary_phone, :secondary_phone)
    params.require(:pregnancy).permit(
      # fields in dashboard
      :status, :last_menstrual_period_time, :last_menstrual_period_weeks, :appointment_date,

      # fields in abortion information
      :procedure_cost, 

      # fields in patient information
      :age, :race_ethnicity, :city, :state, :zip, :employment_status, :income, :household_size, :insurance, :referred_by
    )
    params.require(:clinic).permit! # (fields for clinic) TODO: Implement strong clinic params
  end

end
