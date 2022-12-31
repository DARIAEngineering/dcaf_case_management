require "test_helper"

class PledgeConfigTest < ActiveSupport::TestCase
  before { @config = create :pledge_config }

  describe 'basic validations' do
    it 'should build' do
      assert create(:pledge_config).valid?
    end

    [:contact_email, :billing_email, :phone, :address1, :address2].each do |attrib|
      it "should require #{attrib} to have length under 150 if set" do
        @config[attrib] = 'a' * 151
        refute @config.valid?
        @config[attrib] = 'a' * 150
        assert @config.valid?
        @config[attrib] = nil
        assert @config.valid?
      end
    end
  end
end
