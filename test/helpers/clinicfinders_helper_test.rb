require 'test_helper'

# Test the field parser
class ClinicfindersHelperTest < ActionView::TestCase
  describe 'parse_clinicfinder_field' do
    before do
      @clinic = create :clinic
      @clinic_struct = OpenStruct.new @clinic.attributes
    end

    it 'should parse location specially' do
      assert_equal "#{@clinic.city}, #{@clinic.state}",
                   parse_clinicfinder_field(@clinic_struct, :location)
    end

    it 'should parse distance specially' do
      @clinic_struct.distance = 4.530001

      assert_equal '4.53 miles',
                   parse_clinicfinder_field(@clinic_struct, :distance)
    end

    it 'should parse cost specially' do
      @clinic_struct.cost = 300.02
      assert_equal '$300',
                   parse_clinicfinder_field(@clinic_struct, :cost)
    end

    it 'parses other fields too' do
      assert_equal @clinic.name,
                   parse_clinicfinder_field(@clinic_struct, :name)
    end
  end
end
