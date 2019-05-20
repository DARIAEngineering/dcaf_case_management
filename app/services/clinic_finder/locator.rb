require 'ostruct'
# require_relative './clinic_finder/gestation_helper'
# require_relative 'clinic_finder/affordability_helper'

# Use as follows:
# pt = Patient.find('123');
# finder = ClinicFinder::Locator.new(Clinic.all)
# finder.locate_nearest_clinics pt.zip, limit: 5
# finder.locate_cheapest_clinics limit: 5
module ClinicFinder
  # Core class for accessing stuff. The good stuff is:
  # * ClinicFinder::Locator#locate_nearest_clinics
  # * ClinicFinder::Locator#locate_cheapest_clinics
  class Locator
    include ClinicFinder::Modules::Geocoder

    attr_accessor :clinic_structs
    attr_accessor :patient_context # no reason to not assign this to an obj lvl
    attr_accessor :geocoder

    def initialize(clinics)
      @clinic_structs = clinics.map { |clinic| OpenStruct.new clinic.attributes }
      @patient_context = OpenStruct.new
      @geocoder = Geokit::Geocoders::GoogleGeocoder
    end

    # Return a set of the closest clinics as structs and their attributes,
    # distance included, to a patient's zipcode.
    def locate_nearest_clinics(zipcode, limit: 5)
      @patient_context.location = patient_coordinates_from_zip zipcode
      add_distances_to_clinic_openstructs

      @clinic_structs.sort_by(&:distance).take(limit)
    end

    # Return a set of the cheapest clinics and their attributes.
    # TODO: Implement.
    def locate_cheapest_clinic(gestational_age: 999, limit: 5)
      puts 'NOT IMPLEMENTED YET'
      # @helper = ::ClinicFinder::GestationHelper.new(gestational_age)
      # filtered_clinics = filter_by_params gestational_age, naf_only, medicaid_only

      # @gestational_tier = @helper.gestational_tier
      # decorate_data(available_clinics)
    end
  end
end
