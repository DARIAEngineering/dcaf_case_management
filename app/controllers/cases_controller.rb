class CasesController < ApplicationController
  def index
  	@patient = Patient.new
    @p_case = @patient.cases.build
    @urgent_cases = Case.where(urgent_flag: true)
  end

  def search
    @patient = Patient.new
    @urgent_cases = Case.where(urgent_flag: true)
    name_match = Patient.where(name: params[:keyword])
    primary_match = Patient.where(primary_phone: params[:keyword])
    secondary_match = Patient.where(secondary_phone: params[:keyword])
    patients = name_match + primary_match + secondary_match
    @results = []
    patients.each do |patient|
      @results << patient.cases.most_recent
    end
    render :index
  end

end
