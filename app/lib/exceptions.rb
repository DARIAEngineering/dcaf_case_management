module Exceptions
  class UnauthorizedError < StandardError; end

  class NoGoogleGeoApiKeyError < StandardError; end

  class NoLinesForFundError < StandardError; end
end
