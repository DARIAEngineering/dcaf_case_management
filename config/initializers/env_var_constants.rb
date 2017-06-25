# Definition of line constants
LINES = if ENV['DARIA_LINES'].present?
          ENV['DARIA_LINES'].split(',')
                      .map(&:strip)
                      .map(&:to_sym)
                      .freeze
        else
          %w(DC MD VA).map(&:to_sym).freeze
        end

# Definition of fund
FUND_FULL = ENV['DARIA_FUND_FULL'] || 'DC Abortion Fund'
FUND_DOMAIN = FUND_FULL.gsub(' ', '').downcase
FUND = ENV['DARIA_FUND'] || 'DCAF'
