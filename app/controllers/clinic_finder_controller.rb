class ClinicFinderController < ApplicationController

  def index
    @abortron = Abortron::ClinicFinder.new('clinics.yml')
  end

  def clinic_finder_params
    params.require(:clinic_finder).permit(:patient_zip, :gestational_age)
  end

  def search
    @cheapest = @abortron.locate_cheapest_clinic(params[:patient_zip], params[:gestational_age])
    @nearest = @abortron.locate_cheapest_clinic(params[:patient_zip], params[:gestational_age])
    puts @cheapest.to_s
    puts @nearest.to_s
  end

end