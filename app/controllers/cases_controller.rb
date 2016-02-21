class CasesController < ApplicationController
  def index
  	@patient = Patient.new
    @p_case = @patient.cases.build
    @urgent_cases = Case.where(urgent_flag: true)
  end
end
