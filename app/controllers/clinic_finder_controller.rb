class ClinicFinderController < ApplicationController

  def index
    @abortron = Abortron::ClinicFinder.new('clinics.yml')
  end

  def search
    @cheapest = @abortron.locate_cheapest_clinic(params[:zip], params[:gestation])
    @nearest = @abortron.locate_nearest_clinic(params[:zip], params[:gestation])
    puts @cheapest.to_s
    puts @nearest.to_s
  end

end