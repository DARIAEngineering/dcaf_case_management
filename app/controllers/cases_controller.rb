class CasesController < ApplicationController
  def index
  	@patient = Patient.new
    @urgent_cases = Case.where(urgent_flag: true)
  end

  def search
    @patient = Patient.new
    @urgent_cases = Case.where(urgent_flag: true)
    patients = Patient.where(last_name: params[:keyword])
    @results = []
    patients.each do |patient|
      @results << patient.cases.most_recent
    end
    render :index
  end

end
