# Controller for use with clinic_finder gem; locates nearest clinic
# based on certain info.
class ClinicfindersController < ApplicationController
  def search
    return head :bad_request if params[:zip].blank?

    clinic_finder = ClinicFinder::Locator.new(
      Clinic.where(:zip.nin => [nil, '']),
      gestational_age: (params[:gestation].to_i || 0),
      naf_only: false, # (params[:naf_only] || false),
      medicaid_only: false # (params[:medicaid_only] || false)
    )

    @nearest = clinic_finder.locate_nearest_clinics params[:zip]
    @cheapest = nil # clinic_finder.locate_cheapest_clinic
    respond_to { |format| format.js }
  end
end
