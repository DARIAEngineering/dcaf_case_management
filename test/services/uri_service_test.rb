require 'test_helper'

class URIServiceTest < ActiveSupport::TestCase
  describe 'URI service utility' do
    it 'instantiates a uri from string' do
      uri = URIService.new("some yolo test uri").uri
      assert uri.is_a?(URI)
    end
    
    it 'instantiates nil on invalidURIs' do
      uri = URIService.new(":::::::::::").uri
      assert_nil uri
    end

    it 'instantiates nil on nil' do
      uri = URIService.new(nil).uri
      assert_nil uri
    end

    it 'can force the scheme to use https' do
      u = URIService.new("http://www.someyolourl.com")
     
      assert_equal u.uri.scheme, "http"
      assert_equal u.secure_scheme_uri!.to_s, "https://www.someyolourl.com"
      assert_equal u.uri.scheme, "https"
    end

    it 'can enforce leading slashes while enforcing scheme' do
      u = URIService.new("www.noleadingslashesurl.com")
     
      assert_equal u.secure_scheme_uri!.to_s, "https://www.noleadingslashesurl.com"
      assert_equal u.uri.scheme, "https"
    end
  end
end
