# Methods pertaining to patient search
module PatientSearchable
  extend ActiveSupport::Concern

  class_methods do
    # Case insensitive and phone number format agnostic!
    def search(name_or_phone_str, lines = LINES)
      wildcard_name = "%#{name_or_phone_str}%"
      clean_phone = name_or_phone_str.gsub(/\D/, '')

      base = Patient.where(line: lines)
      matches = base.where('name ilike ?', wildcard_name)
                    .or(base.where('other_contact ilike ?', wildcard_name))
                    .or(base.where('identifier ilike ?', wildcard_name))
      if clean_phone.present?
        clean_phone = "%#{clean_phone}%"
        matches = matches.or(base.where('primary_phone like ?', clean_phone))
                         .or(base.where('other_phone like ?', clean_phone))
      end

      matches.order(updated_at: :desc)
    end
  end
end
