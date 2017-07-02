# Methods pertaining to patient search
module PatientSearchable
  extend ActiveSupport::Concern

  SEARCH_LIMIT = 15

  class_methods do
    # Case insensitive and phone number format agnostic!
    def search(name_or_phone_str, lines = LINES)
      # lines should be an array of symbols
      name_regexp = /#{Regexp.escape(name_or_phone_str)}/i
      clean_phone = name_or_phone_str.gsub(/\D/, '')
      phone_regexp = /#{Regexp.escape(clean_phone)}/
      identifier_regexp = /#{Regexp.escape(name_or_phone_str)}/i

      all_matching_names = find_name_matches name_regexp, lines
      all_matching_phones = find_phone_matches phone_regexp, lines
      all_matching_identifiers = find_identifier_matches(identifier_regexp)

      sort_and_limit_patient_matches(all_matching_names, all_matching_phones, all_matching_identifiers)
    end

    private

    def find_name_matches_user(name_regexp)
      if nonempty_regexp? name_regexp
        primary_names = User.where name: name_regexp
        other_names = User.where other_contact: name_regexp
        return (primary_names | other_names)
      end
      []
    end

    def sort_and_limit_user_matches(*matches)
      all_matches = matches.reduce do |results, matches_of_type|
        results | matches_of_type
      end

      all_matches.sort { |a, b|
        b.updated_at <=> a.updated_at
      }.first(SEARCH_LIMIT)
    end

    def sort_and_limit_patient_matches(*matches)
      all_matches = matches.reduce do |results, matches_of_type|
        results | matches_of_type
      end

      all_matches.sort { |a, b|
        b.updated_at <=> a.updated_at
      }.first(SEARCH_LIMIT)
    end

    def find_name_matches(name_regexp, lines = LINES)
      if nonempty_regexp? name_regexp
        primary_names = Patient.in(line: lines).where name: name_regexp
        other_names = Patient.in(line: lines).where other_contact: name_regexp
        return (primary_names | other_names)
      end
      []
    end

    def find_identifier_matches(identifier_regexp)
      if nonempty_regexp? identifier_regexp
        identifier = Patient.where identifier: identifier_regexp
        return identifier
      end
      []
    end

    def find_phone_matches(phone_regexp, lines = LINES)
      if nonempty_regexp? phone_regexp
        primary_phones = Patient.in(line: lines).where(primary_phone: phone_regexp)
        other_phones = Patient.in(line: lines).where(other_phone: phone_regexp)
        return (primary_phones | other_phones)
      end
      []
    end

    def nonempty_regexp?(regexp)
      # Escaped regexes are always present, so check presence
      # after stripping out standard stuff
      # (opening stuff to semicolon, closing parenthesis)
      regexp.to_s.gsub(/^.*:/, '').chop.present?
    end
  end
end
