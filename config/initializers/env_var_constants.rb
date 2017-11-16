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
FUND_PHONE = ENV['DARIA_FUND_PHONE'] || '202-452-7464'
FUND = ENV['DARIA_FUND'] || 'DCAF'
FUND_FAX_SERVICE = ENV['DARIA_FAX_SERVICE'] || 'www.efax.com'
