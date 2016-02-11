class CasesController < ApplicationController
  def index
  	@patient = Patient.new
    @cases = Case.all
  end
end
