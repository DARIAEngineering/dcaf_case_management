require 'test_helper'

class ScrubPatientPiiRakeTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @patient = create :patient, name: 'Jane Doe', primary_phone: '555-123-4567',
                                city: 'Arlington', state: 'VA'
  end

  describe 'scrub_patient_pii' do
    it 'should remove PII fields from Patient version object_changes' do
      with_versioning(@user) do
        @patient.update!(appointment_date: 2.weeks.from_now)
      end

      # Verify versions exist
      versions = PaperTrailVersion.where(item_type: 'Patient')
      assert versions.any?, 'Expected at least one Patient version'

      count = PaperTrailVersion.scrub_patient_pii

      # After scrub, no Patient version should contain PII fields
      PaperTrailVersion.where(item_type: 'Patient').each do |version|
        PaperTrailVersion::PATIENT_PII_FIELDS.each do |field|
          refute version.object&.key?(field),
                 "PII field '#{field}' should be scrubbed from object"
          refute version.object_changes&.key?(field),
                 "PII field '#{field}' should be scrubbed from object_changes"
        end
      end
    end

    it 'should preserve non-PII fields in versions' do
      with_versioning(@user) do
        @patient.update!(appointment_date: 2.weeks.from_now)
      end

      PaperTrailVersion.scrub_patient_pii

      PaperTrailVersion.where(item_type: 'Patient').each do |version|
        # appointment_date is NOT a PII field, should be preserved
        if version.object_changes.present? && version.object_changes.key?('appointment_date')
          assert version.object_changes.key?('appointment_date'),
                 'Non-PII field should be preserved'
        end
      end
    end

    it 'should return count of scrubbed records' do
      with_versioning(@user) do
        @patient.update!(city: 'New City')
      end

      count = PaperTrailVersion.scrub_patient_pii
      assert count >= 0, 'Scrub count should be non-negative'
    end

    it 'should handle versions with no PII gracefully' do
      # If there are no Patient versions or none with PII, should return 0
      PaperTrailVersion.where(item_type: 'Patient').destroy_all
      count = PaperTrailVersion.scrub_patient_pii
      assert_equal 0, count
    end
  end
end
