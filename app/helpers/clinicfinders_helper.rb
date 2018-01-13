# Fields used in the result table will vary, so...
module ClinicfindersHelper
  def parse_clinicfinder_field(clinic, field)
    case field
    when :location
      "#{clinic.city}, #{clinic.state}"
    when :distance
      "#{clinic[field].round(2)} miles"
    when :cost
      number_to_currency clinic[field], precision: 0
    else
      clinic[field]
    end
  end
end
