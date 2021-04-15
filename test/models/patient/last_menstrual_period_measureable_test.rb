require 'test_helper'
require_relative '../patient_test'

class PatientTest::LastMenstrualPeriodMeasureable < PatientTest
  describe 'last menstrual period calculation concern' do
    before do
      @user = create :user
      @patient = create :patient, initial_call_date: 2.days.ago,
                                  last_menstrual_period_weeks: 9,
                                  last_menstrual_period_days: 2,
                                  appointment_date: 2.days.from_now
    end

    describe 'last_menstrual_period_now_weeks' do
      it 'should return LMP weeks' do
        assert_equal 9, @patient.last_menstrual_period_now_weeks
      end
    end

    describe 'last_menstrual_period_now_days' do
      it 'should return LMP days' do
        assert_equal 4, @patient.last_menstrual_period_now_days
      end
    end

    describe 'last_menstrual_period_at_appt_weeks' do
      it 'should return nil unless appt date is set' do
        @patient.appointment_date = nil
        assert_nil @patient.last_menstrual_period_at_appt_weeks
      end

      it 'should return a calculated LMP weeks on date of appointment' do
        assert_equal 9, @patient.last_menstrual_period_at_appt_weeks
      end
    end

    describe 'last_menstrual_period_at_appt_days' do
      it 'should return nil unless appt date is set' do
        @patient.appointment_date = nil
        assert_nil @patient.last_menstrual_period_at_appt_days
      end

      it 'should return a calculated LMP days on date of appointment' do
        assert_equal 6, @patient.last_menstrual_period_at_appt_days
      end
    end

    describe "last_menstrual_period common features" do
      it 'should cap at appointment date if appointment date is set' do
        @patient.appointment_date = 8.days.ago
        assert_equal 8, @patient.last_menstrual_period_at_appt_weeks
        assert_equal 3, @patient.last_menstrual_period_at_appt_days

        assert_equal 8, @patient.last_menstrual_period_now_weeks
        assert_equal 3, @patient.last_menstrual_period_now_days
      end

      it 'should cap at 280 days' do
        @patient.initial_call_date = 300.days.ago

        assert_equal 40, @patient.last_menstrual_period_at_appt_weeks
        assert_equal 0, @patient.last_menstrual_period_at_appt_days

        assert_equal 40, @patient.last_menstrual_period_now_weeks
        assert_equal 0, @patient.last_menstrual_period_now_days
      end

      it 'should be nil if last_menstrual_period_weeks is not set' do
        @patient.last_menstrual_period_weeks = nil

        assert_nil @patient.last_menstrual_period_at_appt_weeks
        assert_nil @patient.last_menstrual_period_at_appt_days

        assert_nil @patient.last_menstrual_period_now_weeks
        assert_nil @patient.last_menstrual_period_now_days
      end
    end
  end
end
