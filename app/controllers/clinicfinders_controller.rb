# Controller for use with clinic_finder gem; locates nearest clinic
# based on certain info.
class ClinicfindersController < ApplicationController
  def search
    return head :bad_request if params[:zip].blank?

    filtered_clinics = Clinic.where(:zip.nin => [nil, '', Clinic::EXCLUDED_ZIP])
                             .where(:accepts_naf.in => [true, params[:naf_only] == '1'])
                             .where(:accepts_medicaid.in => [true, params[:medicaid_only] == '1'])

    clinic_finder = ClinicFinder::Locator.new filtered_clinics

    @nearest = clinic_finder.locate_nearest_clinics params[:zip]
    @cheapest = nil # clinic_finder.locate_cheapest_clinic
    respond_to { |format| format.js }
  end
end
