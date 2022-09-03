require "test_helper"

class PledgeConfigTest < ActiveSupport::TestCase
  before { @config = create :pledge_config }

  describe 'basic validations' do
    it 'should build' do
      assert create(:pledge_config).valid?
    end

    [:contact_email, :billing_email, :phone, :address1, :address2].each do |attrib|
      it "should require #{attrib}" do
        @config[attrib] = nil
        refute @config.valid?
      end
    end
  end
end
