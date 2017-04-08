module ClinicsHelper
	def return_location
		return nil unless city
		display_location
	end

	def display_location
		city + ', ' + state
	end
end
