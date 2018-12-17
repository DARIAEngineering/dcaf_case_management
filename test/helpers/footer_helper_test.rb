require 'test_helper'

class FooterHelperTest < ActionView::TestCase
  before { create_fax_service_config }

  describe 'fax service' do
    it 'should return the config' do
      fax_link_html = fax_service
      assert_match 'href="http://www.yolofax.com"', fax_link_html
      assert_match '>http://www.yolofax.com</a>', fax_link_html
    end
  end
end
