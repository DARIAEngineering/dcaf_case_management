require 'test_helper'

class FooterHelperTest < ActionView::TestCase
  before { create_fax_service_config }

  describe 'fax service' do
    it 'should return the config' do
      assert_equal 'http://www.yolofax.com', fax_service
    end
  end
end
