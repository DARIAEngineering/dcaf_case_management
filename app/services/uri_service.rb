class URIService
  attr_accessor :uri

  def initialize(uri)
    @uri = URI.parse(URI.encode(uri))
  end

  def secure_scheme!
    @uri.scheme = "https"
  end
end