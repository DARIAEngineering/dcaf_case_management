# Definition of line constants
LINES = if ENV['LINES'].present?
          split_and_strip(ENV['LINES']).map(&:to_sym).freeze
        else
          %w(DC MD VA).map(&:to_sym).freeze
        end

private

def split_and_strip(string)
  string.split(',').map(&:strip)
end
