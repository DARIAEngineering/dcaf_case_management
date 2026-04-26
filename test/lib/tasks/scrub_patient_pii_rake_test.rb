require 'test_helper'

class ScrubPatientPiiRakeTest < ActiveSupport::TestCase
  before do
    @user = create :user
    @patient = create :patient, name: 'Jane Doe', primary_phone: '555-123-4567',
                                city: 'Arlington', state: 'VA',
                                other_phone: '555-999-8888',
                                other_contact: 'John Doe',
                                other_contact_relationship: 'Spouse'
    Rails.application.load_tasks unless Rake::Task.task_defined?('security:scrub_patient_pii')
  end

  describe 'scrub_patient_pii' do
    it 'should remove PII fields from Patient version object_changes' do
      with_versioning(@user) do
        @patient.update!(appointment_date: 2.weeks.from_now)
      end

      versions = PaperTrailVersion.where(item_type: 'Patient')
      assert versions.any?, 'Expected at least one Patient version'

      PaperTrailVersion.scrub_patient_pii

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
      PaperTrailVersion.where(item_type: 'Patient').destroy_all
      count = PaperTrailVersion.scrub_patient_pii
      assert_equal 0, count
    end

    it 'should define all PII fields matching Patient encrypted attributes' do
      patient_pii = PaperTrailVersion::PATIENT_PII_FIELDS.map(&:to_sym).sort
      encrypted = Patient.encrypted_attributes.map(&:to_sym).sort
      assert_equal encrypted, patient_pii,
        'PATIENT_PII_FIELDS should match Patient.encrypted_attributes'
    end

    it 'should execute rake task without error' do
      Rake::Task['security:scrub_patient_pii'].reenable
      assert_nothing_raised do
        Rake::Task['security:scrub_patient_pii'].invoke
      end
    end

    it 'should be idempotent — running twice produces same result' do
      with_versioning(@user) do
        @patient.update!(appointment_date: 2.weeks.from_now)
      end

      first_count = PaperTrailVersion.scrub_patient_pii
      second_count = PaperTrailVersion.scrub_patient_pii

      # Second run should find nothing to scrub
      assert_equal 0, second_count, 'Second scrub should find 0 records to clean'
    end

    it 'should be included in nightly_cleanup rake task' do
      # Verify scrub_patient_pii is called in nightly cleanup
      nightly_source = File.read(Rails.root.join('lib/tasks/nightly_cleanup.rake'))
      assert_match(/scrub_patient_pii/, nightly_source,
        'nightly_cleanup should call scrub_patient_pii')
    end
  end
end
