class CasesController < ApplicationController
  def index
  	@patient = Patient.new
    @patients = Patient.all
  end
end
