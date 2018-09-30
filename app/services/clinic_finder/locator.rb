require 'ostruct'
# require_relative './clinic_finder/gestation_helper'
# require_relative 'clinic_finder/affordability_helper'

# Use as follows:
# pt = Patient.find('123');
# finder = ClinicFinder::Locator.new(
#   Clinic.all,
#   gestational_age: pt.gestational_age, # in days
#   naf_only: true, # Limit results to NAF clinics
#   medicaid_only: true # Limit results to Medicaid clinics
# )
# finder.locate_nearest_clinics pt.zip, limit: 5
# finder.locate_cheapest_clinics limit: 5
module ClinicFinder
  # Core class for accessing stuff. The good stuff is:
  # * ClinicFinder::Locator#locate_nearest_clinics
  # * ClinicFinder::Locator#locate_cheapest_clinics
  class Locator
    include ClinicFinder::Modules::Geocoder

    attr_accessor :clinics
    attr_accessor :clinic_structs
    attr_accessor :patient_context # no reason to not assign this to an obj lvl
    attr_accessor :geocoder

    def initialize(clinics, gestational_age: 0,
                   naf_only: false, medicaid_only: false)
      @clinics = filter_by_params clinics,
                                  gestational_age,
                                  naf_only,
                                  medicaid_only

      @clinic_structs = build_clinic_structs
      @patient_context = OpenStruct.new
      @geocoder = set_geocoder
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

    private

    # Set up mutable clinic structs.
    def build_clinic_structs
      @clinics.map { |clinic| OpenStruct.new clinic.attributes }
    end

    # Based on initialization fields, narrow the list of clinics to
    # just what we need.
    def filter_by_params(clinics, gestational_age, naf_only, medicaid_only)
      filtered_clinics = clinics.keep_if do |clinic|
        gestational_age < (clinic.gestational_limit || 1000) &&
          (naf_only ? clinic.accepts_naf : true) &&
          (medicaid_only ? clinic.accepts_medicaid : true)
      end
      filtered_clinics
    end

    def set_geocoder
      geocoder = Geokit::Geocoders::GoogleGeocoder
      geocoder.api_key = ENV['GOOGLE_GEO_API_KEY'] if ENV['GOOGLE_GEO_API_KEY']

      geocoder
    end
  end
end
