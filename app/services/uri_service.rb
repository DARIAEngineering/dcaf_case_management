class UriService
  attr_accessor :uri

  def initialize(uri)
    begin 
      @uri = URI.parse(URI.encode(uri))
    rescue URI::InvalidURIError
      nil
    end
  end

  def secure_scheme!
    @uri.scheme = "https"
  end
end