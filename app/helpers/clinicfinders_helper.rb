# Fields used in the result table will vary, so...
module ClinicfindersHelper
  def parse_clinicfinder_field(clinic, field)
    case field
    when :location
      t 'clinic_locator.result.location', city: clinic.city, state: clinic.state
    when :distance
      t 'clinic_locator.result.distance', miles: clinic[field].round(2)
    when :cost
      number_to_currency clinic[field], precision: 0
    when :gestational_limit
      return t('clinic_locator.result.not_specified') unless clinic.gestational_limit.present?
      weeks = (clinic.gestational_limit / 7).to_i
      days = (clinic.gestational_limit % 7).to_i
      t 'clinic_locator.result.goes_to', weeks: weeks, days: days
    when :accepts_naf
      word = clinic[field] ? 'yes' : 'no'
      t "common.#{word}"
    else
      clinic[field]
    end
  end
end
