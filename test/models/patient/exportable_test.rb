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

    describe 'fulfillments related' do
      before do
        @fulfilled_patient = create :patient
        create :fulfillment patient: @fulfilled_patient,
                            fulfilled: true,
                            procedure_date: 2.days.ago,
                            gestation_at_procedure: 50,
                            fund_payout: 30,
                            check_number: 'A10',
                            date_of_check: 3.days.ago
      end

      describe 'fulfilled' do
        it 'should return nil if no fulfillment' do
          assert_nil @patient.fulfilled
        end

        it 'should return fulfillment status' do
          @patient.build_fulfillment(fulfilled: false).save
          assert_nil @patient.fulfilled
          @patient.fulfillment.update fulfilled: true
          assert @patient.fulfilled
        end
      end

      describe 'procedure_date' do
        it 'should return nil if no fulfillment' do
          assert_nil @patient.procedure_date
        end

        it 'should show procedure_date when fulfillment is set' do
          create :fulfillment patient: patient, procedure_date: 2.days.ago
          assert_equal 2.days.ago.to_date, @patient.procedure_date
        end
      end

      describe 'gestation_at_procedure' do
        it 'should return nil if no fulfillment' do
          assert_nil @patient.gestation_at_procedure
        end

        it 'should show gestation_at_procedure when fulfillment is set' do
          create :fulfillment patient: patient, gestation_at_procedure: 50
          assert_equal 50, @patient.gestation_at_procedure
        end
      end

      describe 'fund_payout' do
        it 'should return nil if no fulfillment' do
          assert_nil @patient.fund_payout
        end

        it 'should show fund_payout when fulfillment is set' do
          create :fulfillment patient: patient, fund_payout: 50
          assert_equal 50, @patient.fund_payout
        end
      end

      describe 'check_number' do
        it 'should return nil if no fulfillment' do
          assert_nil @patient.check_number
        end

        it 'should show fund_payout when fulfillment is set' do
          create :fulfillment patient: patient, check_number: 'A20'
          assert_equal 'A20', @patient.check_number
        end
      end

      describe 'date_of_check' do
        it 'should return nil if no fulfillment' do
          assert_nil @patient.date_of_check
        end

        it 'should show date_of_check when fulfillment is set' do
          create :fulfillment patient: patient, date_of_check: 2.days.ago
          assert_equal 2.days.ago.to_date, @patient.date_of_check
        end
      end
    end

    describe 'call related' do
      before do
        @first_call = 5.days.ago
        @last_call = 1.days.ago
        create :call, patient: @patient, created_at: @first_call, status: :reached_patient
        create :call, patient: @patient, created_at: 3.days.ago, status: :left_message
        create :call, patient: @patient, created_at: @last_call, status: :left_message

      end

      describe 'first_call_timestamp' do
        it 'should be nil if no calls' do
          @patient.calls.destroy_all
          assert_nil @patient.first_call_timestamp
        end
        it 'should return datetime of first call' do
          assert_equal @first_call, @patient.first_call_timestamp
        end
      end
  
      describe 'last_call_timestamp' do
        it 'should be nil if no calls' do
          @patient.calls.destroy_all
          assert_nil @patient.last_call_timestamp
        end
        it 'should return datetime of last call' do
          assert_equal @first_call, @patient.first_call_timestamp

        end
      end  

      describe 'call_count' do
        it 'should return count of calls' do
          raise

        end
      end
  
      describe 'reached_patient_call_count' do
        it 'should return count of reached calls' do
          raise
        end
      end  
    end

    describe 'export_clinic_name' do
      it 'should return nil if no clinic' do
        assert_nil @patient.export_clinic_name
      end

      it 'should return clinic name if set' do
        @clinic = create :clinic
        @patient.update clinic: @clinic
        assert_equal @clinic.name, @patient.export_clinic_name
      end
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
    
    describe 'external pledge related' do
      describe 'external_pledge_count' do
        raise
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
