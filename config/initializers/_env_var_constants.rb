# Definition of line constants
LINES = if ENV['DARIA_LINES'].present?
          ENV['DARIA_LINES'].split(',')
                      .map(&:strip)
                      .map(&:to_sym)
                      .freeze
        else
          %w(DC MD VA).map(&:to_sym).freeze
        end

# Where the emails come from
FUND_MAILER_DOMAIN = ENV['FUND_MAILER_DOMAIN'] || 'dcabortionfund.org'
