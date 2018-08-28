require 'ostruct'

module ClinicFinder
  # Functionality pertaining to geography
  module Modules
    # Nesting due to rails autoload
    module Geocoder
      # Get a patient's latitude and longitude.
      def get_patient_coordinates_from_zip(zipcode)
        patient_location = @geocoder.geocode zipcode
        @patient_context.location = patient_location.ll
      end

      # Attach a distance field to individual clinic_structs for sorting.
      def add_distances_to_clinic_openstructs
        add_clinic_full_address
        determine_clinic_coordinates
        calculate_distances
      end

      private

      # Attach a full address for consumption by the geocoder.
      def add_clinic_full_address
        @clinic_structs.each do |clinic|
          addr = if clinic.city && clinic.state
                   "#{clinic.street_address}, " \
                   "#{clinic.city}, #{clinic.state}"
                 end

          clinic.full_address = addr
        end
      end

      # Attach a clinic's latitude and longitude.
      def determine_clinic_coordinates
        @clinic_structs.each do |clinic|
          # The Geocoder is looking for something like this:
          # {name: 'Oakland Clinic', address: '101 Main St, Oakland, CA'}
          if clinic.ll
            clinic.coordinates = clinic.ll.
          location = @geocoder.geocode clinic.full_address
          coordinates = location.ll.split(',').map(&:to_f)

          clinic.coordinates = Geokit::LatLng.new(coordinates[0], coordinates[1])
        end
      end

      # Calculate distance between a clinic and the patient's zipcode.
      def calculate_distances
        @clinic_structs.each do |clinic|
          clinic.distance = clinic.coordinates
                                  .distance_to(@patient_context.location)
        end
      end
    end
  end
end
