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
      u.secure_scheme!
      assert_equal u.secure_scheme!, "https"
    end
  end
end
