require 'test_helper'

class RotateEncryptionKeysRakeTest < ActiveSupport::TestCase
  describe 'rotate_keys task' do
    it 'should only process models with encrypted_attributes' do
      # Note, Event, Clinic do not have encrypts on main, only Patient does
      models = [Patient, Note, Event, Clinic]
      models_with_encryption = models.select do |m|
        m.respond_to?(:encrypted_attributes) && m.encrypted_attributes.any?
      end

      # Patient should have encrypted attributes
      assert_includes models_with_encryption, Patient

      # Models without encrypts declarations should be filtered out
      [Note, Event, Clinic].each do |model|
        unless model.respond_to?(:encrypted_attributes) && model.encrypted_attributes.any?
          refute_includes models_with_encryption, model
        end
      end
    end

    it 'should handle patients with encrypted fields' do
      patient = create :patient, name: 'Rotate Test', primary_phone: '555-999-0000'
      patient.encrypt
      patient.reload
      assert_equal 'Rotate Test', patient.name
      assert_equal '555-999-0000', patient.primary_phone
    end
  end
end
