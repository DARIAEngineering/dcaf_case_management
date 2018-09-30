require 'ostruct'

module ClinicFinder
  # Functionality pertaining to geography
  module Modules
    # Nesting due to rails autoload
    module Geocoder
      # Get a patient's latitude and longitude.
      def patient_coordinates_from_zip(zipcode)
        patient_location = @geocoder.geocode zipcode
        patient_location.ll
      end

      # Attach a distance field to individual clinic_structs for sorting.
      def add_distances_to_clinic_openstructs
        pt_latlng = @patient_context.location
        @clinic_structs.each do |clinic|
          clinic.distance = Geokit::LatLng.new(*clinic.coordinates)
                                          .distance_to(pt_latlng)
        end
      end
    end
  end
end
