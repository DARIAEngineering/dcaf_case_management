class CasesController < ApplicationController
  def index
    @urgent_cases = Case.where(urgent_flag: true)
  end

  def search
    @urgent_cases = Case.where(urgent_flag: true)
    last_match = Patient.where(last_name: params[:keyword])
    first_match = Patient.where(first_name: params[:keyword])
    patients = last_match + first_match
    @results = []
    patients.each do |patient|
      @results << patient.cases.most_recent
    end
    render :index
  end

end
