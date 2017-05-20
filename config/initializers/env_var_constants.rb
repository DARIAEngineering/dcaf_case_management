# Definition of line constants
LINES = if ENV['LINES'].present?
          ENV['LINES'].split(',')
                      .map(&:strip)
                      .map(&:to_sym)
                      .freeze
        else
          %w(DC MD VA).map(&:to_sym).freeze
        end

# Definition of fund
FUND = ENV['FUND'] || 'DC Abortion Fund'
FUND_ACRONYM = ENV['DARIA_FUND_ABBREV'] || 'DCAF'
