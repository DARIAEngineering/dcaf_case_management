require 'test_helper'

class UriServiceTest < ActiveSupport::TestCase
  describe 'URI service utility' do
    it 'instantiates a uri from string' do
      uri = UriService.new("example.net").uri
      assert uri.is_a?(URI)
    end
    
    it 'instantiates nil on invalidURIs' do
      uri = UriService.new(":::::::::::").uri
      assert_nil uri

      uri = UriService.new("some yolo test uri").uri
      refute uri.is_a?(URI)
    end

    it 'instantiates nil on nil' do
      uri = UriService.new(nil).uri
      assert_nil uri
    end

    it 'can force the scheme to use https' do
      u = UriService.new("http://www.someyolourl.com")

      assert_equal u.uri.scheme, "https"
    end

    it 'can enforce leading slashes while enforcing scheme' do
      # add scheme
      u = UriService.new("www.noleadingslashesurl.com")
     
      assert_equal "https://www.noleadingslashesurl.com", u.uri.to_s
      assert_equal "https", u.uri.scheme

      # convert http to https
      u = UriService.new("http://unsafe.biz/path")

      assert_equal u.uri.to_s, "https://unsafe.biz/path"
      assert_equal u.uri.scheme, "https"
    end
  end
end
