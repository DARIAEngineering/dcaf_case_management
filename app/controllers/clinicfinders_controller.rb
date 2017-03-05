class ClinicfindersController < ApplicationController

  def index
  end

  def search
    @abortron = Abortron::ClinicFinder.new("#{Rails.root}/clinics.yml")
    @nearest = @abortron.locate_nearest_clinic patient_zipcode: params[:zip].to_i.to_s,
                                                  gestational_age: params[:gestation].to_i
    @cheapest = @abortron.locate_cheapest_clinic(gestational_age: params[:gestation].to_i)
    respond_to { |format| format.js }
  end

end
