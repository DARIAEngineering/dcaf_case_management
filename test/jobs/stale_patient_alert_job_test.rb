require 'test_helper'

class StalePatientAlertJobTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @patient = create :patient
  end

  describe 'Patient.stale scope' do
    it 'should return patients with no activity past threshold' do
      @patient.update_columns(updated_at: 10.days.ago)
      stale = Patient.stale(7)
      assert_includes stale, @patient
    end

    it 'should exclude patients with recent activity' do
      @patient.update_columns(updated_at: 1.day.ago)
      stale = Patient.stale(7)
      refute_includes stale, @patient
    end

    it 'should exclude resolved_without_fund patients' do
      @patient.update_columns(updated_at: 10.days.ago, resolved_without_fund: true)
      stale = Patient.stale(7)
      refute_includes stale, @patient
    end

    it 'should exclude pledge_sent patients' do
      @patient.update_columns(updated_at: 10.days.ago, pledge_sent: true)
      stale = Patient.stale(7)
      refute_includes stale, @patient
    end
  end

  describe 'Config.stale_patient_days' do
    it 'should have stale_patient_days enum value of 27' do
      assert_equal 27, Config.config_keys['stale_patient_days']
    end

    it 'should return default of 5 when no config exists' do
      days = Config.stale_patient_days
      assert_equal 5, days
    end
  end

  describe 'stale patient day options validation' do
    it 'should accept valid stale day options' do
      [2, 3, 5, 7, 14, 30].each do |days|
        assert_includes Config::STALE_PATIENT_DAY_OPTIONS, days
      end
    end
  end

  describe 'Patient#stale? instance method' do
    it 'should return true for stale patients' do
      @patient.update_columns(updated_at: 10.days.ago)
      assert @patient.stale?
    end

    it 'should return false for recently updated patients' do
      @patient.update_columns(updated_at: 1.day.ago)
      refute @patient.stale?
    end

    it 'should return false for resolved_without_fund patients' do
      @patient.update_columns(updated_at: 10.days.ago, resolved_without_fund: true)
      refute @patient.stale?
    end

    it 'should return false for pledge_sent patients' do
      @patient.update_columns(updated_at: 10.days.ago, pledge_sent: true)
      refute @patient.stale?
    end

    it 'should match scope results' do
      @patient.update_columns(updated_at: 10.days.ago)
      scope_includes = Patient.stale(Config.stale_patient_days).include?(@patient)
      assert_equal scope_includes, @patient.stale?
    end
  end
end
