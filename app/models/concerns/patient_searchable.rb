# Methods pertaining to patient search
module PatientSearchable
  extend ActiveSupport::Concern

  DEFAULT_SEARCH_LIMIT = 15

  class_methods do
    # Case insensitive and phone number format agnostic!
    # pass `search_limit: nil` for no limit.
    #
    # Search is performed in-memory after loading records because
    # Patient PII fields are encrypted with ActiveRecord Encryption.
    # Encrypted fields cannot be searched with SQL LIKE/ILIKE, so we
    # decrypt and filter in Ruby. This is performant for DARIA's
    # dataset size (typically a few hundred active patients per line).
    def search(name_or_phone_str, lines: nil, search_limit: DEFAULT_SEARCH_LIMIT)
      search_term = name_or_phone_str.downcase
      clean_phone = name_or_phone_str.gsub(/\D/, '')

      base = Patient
      base = base.where(line: lines) if lines

      matches = base.select do |patient|
        name_match = patient.name&.downcase&.include?(search_term) ||
                     patient.other_contact&.downcase&.include?(search_term) ||
                     patient.identifier&.downcase&.include?(search_term)

        phone_match = clean_phone.present? && (
          patient.primary_phone&.include?(clean_phone) ||
          patient.other_phone&.include?(clean_phone)
        )

        name_match || phone_match
      end

      matches = matches.sort_by(&:updated_at).reverse
      matches = matches.first(search_limit) if search_limit.present?
      matches
    end
  end
end
