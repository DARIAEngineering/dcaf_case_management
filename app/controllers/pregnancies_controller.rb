class PregnanciesController < ApplicationController
  def index
  	@patient = Patient.new
    @pregnancies = @patient.pregnancies.build
    @urgent_cases = Pregnancy.where(urgent_flag: true)
  end
end
