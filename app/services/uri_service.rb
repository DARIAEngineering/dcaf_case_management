class UriService
  attr_accessor :uri

  def initialize(uri)
    return nil if uri.nil?

    begin 
      @uri = URI.parse(URI.encode(uri))
    rescue URI::InvalidURIError
      nil
    end
  end

  def secure_scheme_uri!
    fix_leading_slashes
    @uri.scheme = "https"
    @uri
  end

  def fix_leading_slashes
    if @uri.scheme.nil? && @uri.host.nil? && @uri.path.present?
      @uri.host = @uri.path
      @uri.path = ""
    end
  end
end