class ClinicfindersController < ApplicationController

  def index
    # @abortron = Abortron::ClinicFinder.new('clinics.yml')
  end

  def search

    @abortron = Abortron::ClinicFinder.new("#{Rails.root}/clinics.yml")
    @nearest = @abortron.locate_nearest_clinic patient_zipcode: params[:zip].to_i.to_s,
                                                  gestational_age: params[:gestation].to_i
    @cheapest = @abortron.locate_cheapest_clinic(gestational_age: params[:gestation].to_i)
    puts @cheapest.to_s
    puts @nearest.to_s
    redirect_to clinicfinders_path

    # puts @nearest.to_s
  end

end




# file = File.join(File.dirname(__FILE__), '../../clinics.yml')