require 'test_helper'
require 'ostruct'

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

    it 'should parse gestational_limit specially' do
      @clinic_struct.gestational_limit = 50
      assert_equal '7w1d',
                   parse_clinicfinder_field(@clinic_struct, :gestational_limit)

      @clinic_struct.gestational_limit = nil
      assert_equal 'Not specified',
                   parse_clinicfinder_field(@clinic_struct, :gestational_limit)
    end

    it 'should parse accepts_naf specifically' do
      @clinic_struct.accepts_naf = false
      assert_equal 'No',
                   parse_clinicfinder_field(@clinic_struct, :accepts_naf)

      @clinic_struct.accepts_naf = true
      assert_equal 'Yes',
                   parse_clinicfinder_field(@clinic_struct, :accepts_naf)
    end

    it 'parses other fields too' do
      assert_equal @clinic.name,
                   parse_clinicfinder_field(@clinic_struct, :name)
    end
  end
end
