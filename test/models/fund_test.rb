require "test_helper"

class FundTest < ActiveSupport::TestCase
  before do
    @fund = Fund.first # created during setup
  end

  describe 'basic validations' do
    it 'should build' do
      assert create(:fund).valid?
    end

    [:name, :subdomain, :domain, :full_name].each do |attrib|
      it "should require #{attrib}" do
        @fund[attrib] = nil
        refute @fund.valid?
      end
    end

    [:name, :subdomain].each do |attrib|
      it "should be unique on #{attrib}" do
        nonunique_fund = create :fund
        nonunique_fund[attrib] = @fund[attrib]
        refute nonunique_fund.valid?
      end
    end
  end

  describe 'scoping by fund' do
    before { @fund2 = create :fund }

    it 'should separate objects by fund' do
      [@fund, @fund2].each do |fund|
        ActsAsTenant.with_tenant(fund) do
          create :patient
        end
      end

      # The funds should see only one of them
      ActsAsTenant.with_tenant(@fund) do
        assert_equal 1, Patient.count
        @pt1 = Patient.first
      end
      ActsAsTenant.with_tenant(@fund2) do
        assert_equal 1, Patient.count
        @pt2 = Patient.first
      end
      refute_equal @pt1.id, @pt2.id
      refute_equal @pt1.fund_id, @pt2.fund_id

      # But there should be two patients in db
      ActsAsTenant.current_tenant = nil
      ActsAsTenant.test_tenant = nil
      assert_equal 2, Patient.count 
    end
  end
end
