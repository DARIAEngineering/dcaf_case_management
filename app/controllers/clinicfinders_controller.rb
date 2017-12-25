# Controller for use with clinic_finder gem; locates nearest clinic
# based on certain info.
class ClinicfindersController < ApplicationController
  def index; end

  def search
    puts 'searching fasdlfndsl'
    puts params
    @abortron = ClinicFinder::Locator.new(
      Clinic.all, gestational_age: (params[:gestation].to_i || 0),
                  naf_only: false, # (params[:naf_only] || false),
                  medicaid_only: false # (params[:medicaid_only] || false)
    )

    @nearest = @abortron.locate_nearest_clinics params[:zip]
    @cheapest = nil # @abortron.locate_cheapest_clinic
    puts @nearest
    respond_to { |format| format.js }
  end
end
