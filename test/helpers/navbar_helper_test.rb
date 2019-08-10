require 'test_helper'

class NavbarHelperTest < ActionView::TestCase
  include ERB::Util

  describe 'cm_resources_link' do
    before do
      @config = create :config, config_key: 'resources_url',
                                config_value: { options: ['https://www.google.com'] }
    end

    it 'should return nil if config is not set' do
      @config.update config_value: { options: [] }
      refute cm_resources_link
    end

    it 'should return a link if config set' do
      expected_link = '<li><a target="_blank" href="https://www.google.com">CM Resources</a></li>'
      assert_equal expected_link, cm_resources_link
    end
  end
end
