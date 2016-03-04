class PregnancyCasesController < ApplicationController
  def index
  	@patient = Patient.new
    @pregnancy_cases = @patient.pregnancy_cases.build
    @urgent_cases = PregnancyCase.where(urgent_flag: true)
  end
end
