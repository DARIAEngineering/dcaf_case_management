require "test_helper"

class LineTest < ActiveSupport::TestCase
  before { @line = create :line }

  describe 'validations' do
    it 'should build' do
      assert create(:line).valid?
    end

    [:name].each do |attrib|
      it "should require #{attrib}" do
        @line[attrib] = nil
        refute @line.valid?
      end
    end

    it 'should be unique on name within a fund' do
      create :line, name: 'DC'
      line2 = create :line
      assert line2.valid?
      line2.name = 'DC'
      refute line2.valid?

      ActsAsTenant.with_tenant(create(:fund)) do
        line3 = create :line, name: 'DC'
        assert line3.valid?
      end
    end
  end
end
