class CasesController < ApplicationController
  def index
  	@patient = Patient.new
    @urgent_cases = Case.where(urgent_flag: true)
  end
end
