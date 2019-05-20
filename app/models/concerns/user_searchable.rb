# Methods pertaining to patient search
module UserSearchable
  extend ActiveSupport::Concern

  SEARCH_LIMIT = 15
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  class_methods do
    def search(name_or_email_str)
      regexp = /#{Regexp.escape(name_or_email_str)}/i

      all_matching_names = find_name_matches regexp
      all_matching_emails = find_email_matches regexp

      sort_and_limit_user_matches(all_matching_names, all_matching_emails)
    end

    private

    def find_name_matches(name_regexp)
      if nonempty_regexp? name_regexp
        names = User.where name: name_regexp
        return names
      end
      []
    end

    def find_email_matches(email_regexp)
      if nonempty_regexp? email_regexp
        emails = User.where email: email_regexp
        return emails
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

    def nonempty_regexp?(regexp)
      # Escaped regexes are always present, so check presence
      # after stripping out standard stuff
      # (opening stuff to semicolon, closing parenthesis)
      regexp.to_s.gsub(/^.*:/, '').chop.present?
    end
  end
end
