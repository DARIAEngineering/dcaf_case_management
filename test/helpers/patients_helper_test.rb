require 'test_helper'

class PatientsHelperTest < ActionView::TestCase
  describe 'weeks_options' do
    it 'should pluralize properly' do
      assert_equal '1 week', weeks_options.second[0]
      assert_equal '2 weeks', weeks_options.third[0]
      assert_equal 1, weeks_options.select { |x| /week$/.match x[0] }.count
    end

    it 'should have 30 entries' do
      assert_equal 31, weeks_options.count
    end
  end

  describe 'days_options' do
    it 'should pluralize properly' do
      assert_equal '0 days', days_options.second[0]
      assert_equal '1 day', days_options.third[0]
      assert_equal '2 days', days_options.fourth[0]
      assert_equal 1, days_options.select { |x| /day$/.match x[0] }.count
    end

    it 'should have 7 entries' do
      assert_equal 8, days_options.count
    end
  end

  describe 'insurance options' do
    describe 'with a config' do
      before { create_insurance_config }

      it 'should include the option set' do
        expected_insurance_options_array = [nil, 'DC Medicaid', 'Other state Medicaid', 'No insurance', "Don't know", 'Other (add to notes)']
        assert_same_elements insurance_options, expected_insurance_options_array
      end
    end

    describe 'without a config' do
      it 'should create a config and return proper options' do
        assert_difference 'Config.count', 1 do
          @options = insurance_options
        end

        expected_insurance_array = [nil,
                                    'No insurance',
                                    'Don\'t know',
                                    'Other (add to notes)']
        assert_same_elements @options, expected_insurance_array
        assert Config.find_by(config_key: 'insurance')
      end
    end

    describe 'clinic options' do
      before do
        @active = create :clinic, name: 'active clinic', active: true
        @inactive = create :clinic, name: 'closed clinic', active: false
      end

      it 'should return all clinics' do
        expected_clinic_array = [nil,
                                 [@active.name, @active.id],
                                 ['--- INACTIVE CLINICS ---', nil],
                                 ["(Not currently working with DCAF) - #{@inactive.name}", @inactive.id]]

        assert_same_elements clinic_options, expected_clinic_array
      end
    end
  end

  %w(race_ethnicity employment_status insurance income referred_by
     household_size).each do |array|
    describe "#{array}_options" do
      it "should be a usable array - #{array}_options" do
        options_array = send("#{array}_options".to_sym)
        assert options_array.class == Array
        assert options_array.count > 1
      end
    end
  end
end
