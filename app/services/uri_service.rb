class UriService
  attr_accessor :uri

  def initialize(uri)
    return nil if uri.blank?

    begin 
      @uri = URI.parse(uri)

      if @uri.class == URI::Generic
        # probably missing https. raise error so we can try again
        raise URI::InvalidURIError
      end

    rescue URI::InvalidURIError
      # Maybe we forgot the scheme... try adding
      begin
        @uri = URI.parse("https://" + uri)
      rescue URI::InvalidURIError
        # nope!
        @uri = nil
        return
      end
    end

    # force https
    secure_scheme_uri!
  end

  def secure_scheme_uri!
    @uri.scheme = "https"
    return @uri
  end
end