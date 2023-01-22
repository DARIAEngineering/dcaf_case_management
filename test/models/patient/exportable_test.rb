require 'test_helper'
require_relative '../patient_test'

class PatientTest::Exportable < PatientTest
  describe 'export concern methods' do
    before do
      @patient = create :patient
      @archived = create :archived_patient
    end

    describe 'get_line' do
      it 'should return the line name' do
        assert_equal @patient.line.name, @patient.get_line
      end
    end

    describe 'fulfilled' do
      it 'should return fulfillment status' do
        refute @patient.fulfilled
        @patient.build_fulfillment(fulfilled: false).save
        refute @patient.fulfilled
        @patient.fulfillment.update fulfilled: true
        assert @patient.fulfilled
      end
    end

    describe 'archived?' do
      it 'should return false if patient' do
        refute @patient.archived?
      end

      it 'should return true if archived' do
        assert @archived.archived?
      end
    end

    describe 'household size tests' do
      # get_household_size_children
      # get_household_size_adults
      it 'should return prefer not to answer with -1' do
        @patient.update household_size_children: -1, household_size_adults: -1
        assert_equal 'Prefer not to answer', @patient.get_household_size_children
        assert_equal 'Prefer not to answer', @patient.get_household_size_adults
      end

      it 'should return number otherwise' do
        @patient.update household_size_children: 4, household_size_adults: 3
        assert_equal 4, @patient.get_household_size_children
        assert_equal 3, @patient.get_household_size_adults
      end

      it 'should null out for archived patients' do
        archived = create :archived_patient
        assert_nil archived.get_household_size_children
        assert_nil archived.get_household_size_adults
      end
    end

    describe 'procedure_date' do
      raise
    end

    describe 'gestation_at_procedure' do
      raise
    end

    describe 'fund_payout' do
      raise
    end

    describe 'check_number' do
      raise
    end

    describe 'date_of_check' do
      raise
    end

    describe 'first_call_timestamp' do
      raise
    end

    describe 'last_call_timestamp' do
      raise
    end

    describe 'call_count' do
      raise
    end

    describe 'reached_patient_call_count' do
      raise
    end

    describe 'export_clinic_name' do
      raise
    end


    describe 'preferred language tests' do
      it 'should return the right language' do
        ['', nil].each do |language|
          @patient.update language: language
          assert_equal @patient.preferred_language, 'English'
        end

        @patient.update language: 'Spanish'
        assert_equal @patient.preferred_language, 'Spanish'
      end
    end

    describe 'external_pledge_count' do

    end

    describe "external_pledge_sum" do
      it "returns 0 if no pledges" do
        assert_equal @patient.external_pledge_sum, 0
      end

      it "returns sum of pledges when they exist" do
        @patient.external_pledges.create attributes_for(:external_pledge, amount: 100)
        @patient.external_pledges.create attributes_for(:external_pledge, amount: 200)
        assert_equal @patient.external_pledge_sum, 300
      end
    end

    describe 'all_external_pledges' do
      raise
    end

    describe 'all_practical_supports' do
      raise
    end



    describe 'age range tests' do
      it 'should return the right age for numbers' do
        @patient.age = nil
        assert_equal @patient.age_range, :not_specified

        [15, 17].each do |age|
          @patient.update age: age
          assert_equal @patient.age_range, :under_18
        end

        [18, 20, 24].each do |age|
          @patient.update age: age
          assert_equal @patient.age_range, :age18_24
        end

        [25, 30, 34].each do |age|
          @patient.update age: age
          assert_equal @patient.age_range, :age25_34
        end

        [35, 40, 44].each do |age|
          @patient.update age: age
          assert_equal @patient.age_range, :age35_44
        end

        [45, 50, 54].each do |age|
          @patient.update age: age
          assert_equal @patient.age_range, :age45_54
        end

        [55, 60, 100].each do |age|
          @patient.update age: age
          assert_equal @patient.age_range, :age55plus
        end

        [101, 'yolo'].each do |bad_age|
          @patient.age = bad_age
          assert_equal @patient.age_range, :bad_value
        end
      end
    end

    describe 'get_field_value_for_serialization' do
      it 'should clean and handle regular values' do
        raise
      end

      it 'should clean and join arrays' do
        raise
      end
    end
  end
end
