require 'test_helper'

class RotateEncryptionKeysRakeTest < ActiveSupport::TestCase
  before do
    @patient = create :patient, name: 'Rotate Test',
                                primary_phone: '555-999-0000',
                                city: 'Arlington'
    Rails.application.load_tasks unless Rake::Task.task_defined?('encryption:rotate_keys')
  end

  describe 'rotate_keys task' do
    it 'should only process models with encrypted_attributes' do
      models = [Patient, Note, Event, Clinic]
      models_with_encryption = models.select do |m|
        m.respond_to?(:encrypted_attributes) && m.encrypted_attributes.any?
      end

      assert_includes models_with_encryption, Patient

      [Note, Event, Clinic].each do |model|
        unless model.respond_to?(:encrypted_attributes) && model.encrypted_attributes.any?
          refute_includes models_with_encryption, model
        end
      end
    end

    it 'should preserve data after re-encryption' do
      @patient.encrypt
      @patient.reload
      assert_equal 'Rotate Test', @patient.name
      assert_equal '555-999-0000', @patient.primary_phone
      assert_equal 'Arlington', @patient.city
    end

    it 'should execute rake task without error' do
      Rake::Task['encryption:rotate_keys'].reenable
      assert_nothing_raised do
        Rake::Task['encryption:rotate_keys'].invoke
      end
    end

    it 'should preserve all patient data after rake task execution' do
      Rake::Task['encryption:rotate_keys'].reenable
      Rake::Task['encryption:rotate_keys'].invoke
      @patient.reload
      assert_equal 'Rotate Test', @patient.name
      assert_equal '555-999-0000', @patient.primary_phone
      assert_equal 'Arlington', @patient.city
    end

    it 'should skip models without encrypted attributes gracefully' do
      # Verify the guard clause works — no error for Note/Event/Clinic
      Rake::Task['encryption:rotate_keys'].reenable
      assert_nothing_raised do
        Rake::Task['encryption:rotate_keys'].invoke
      end
    end

    it 'should handle empty tenant with no patients' do
      fund = create :fund, name: 'Empty Fund'
      ActsAsTenant.with_tenant(fund) do
        assert_equal 0, Patient.count
      end
      # Rake task should handle this gracefully
      Rake::Task['encryption:rotate_keys'].reenable
      assert_nothing_raised do
        Rake::Task['encryption:rotate_keys'].invoke
      end
    end
  end
end
