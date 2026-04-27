require 'test_helper'

class EncryptPatientColumnsRakeTest < ActiveSupport::TestCase
  before do
    @patient = create :patient, name: 'Test Patient',
                                primary_phone: '555-111-2222',
                                other_phone: '555-333-4444',
                                other_contact: 'Jane Doe',
                                other_contact_relationship: 'Sister',
                                city: 'Washington',
                                state: 'DC',
                                county: 'DC',
                                zipcode: '20001'
  end

  describe 'encrypts declarations' do
    it 'should declare direct PII identifier columns as encrypted' do
      encrypted_attrs = Patient.encrypted_attributes
      %i[name primary_phone other_phone other_contact
         other_contact_relationship city].each do |attr|
        assert_includes encrypted_attrs, attr,
          "Expected #{attr} to be in encrypted_attributes"
      end
    end

    it 'should NOT encrypt geographic-only fields (state/county/zipcode)' do
      encrypted_attrs = Patient.encrypted_attributes
      %i[state county zipcode].each do |attr|
        refute_includes encrypted_attrs, attr,
          "Expected #{attr} to NOT be encrypted (kept clear for PaperTrail visibility)"
      end
    end

    it 'should use deterministic encryption for primary_phone' do
      # Deterministic encryption allows querying by exact value, needed for
      # the unique index on [:primary_phone, :fund_id]
      scheme = Patient.encryption_scheme_for(:primary_phone)
      assert scheme.deterministic?
    end

    it 'should use non-deterministic encryption for name' do
      scheme = Patient.encryption_scheme_for(:name)
      refute scheme.deterministic?
    end

    it 'should redact PII values in PaperTrail versions while recording that the field changed' do
      user = create :user
      with_versioning(user) do
        @patient.update!(name: 'Changed Name')
        version = @patient.versions.reorder(id: :desc).first
        next unless version

        # The audit trail records that `name` changed
        assert version.object_changes.key?('name'),
          'PaperTrail should record that name changed'

        # But the actual values are redacted (no plaintext PII)
        serialized = version.object_changes.to_json + (version.object || {}).to_json
        refute_includes serialized, 'Test Patient',
          'Old PII value should not appear in version'
        refute_includes serialized, 'Changed Name',
          'New PII value should not appear in version'
        assert_includes version.object_changes['name'].to_s,
          PaperTrailVersion::REDACTED_PLACEHOLDER,
          'Redacted placeholder should be present in object_changes'
      end
    end

    it 'should leave non-PII field changes untouched in PaperTrail versions' do
      user = create :user
      with_versioning(user) do
        @patient.update!(state: 'MD', city: 'Baltimore')
        version = @patient.versions.reorder(id: :desc).first
        next unless version

        # state is NOT encrypted/redacted -> plaintext visible in audit
        assert_includes version.object_changes['state'].to_s, 'MD'
        # city IS redacted (still in encrypted/redacted set)
        refute_includes version.object_changes['city'].to_s, 'Baltimore'
      end
    end
  end

  describe 'encrypted field round-trips' do
    it 'should round-trip all encrypted fields correctly' do
      @patient.reload
      assert_equal 'Test Patient', @patient.name
      assert_equal '555-111-2222', @patient.primary_phone
      assert_equal '555-333-4444', @patient.other_phone
      assert_equal 'Jane Doe', @patient.other_contact
      assert_equal 'Sister', @patient.other_contact_relationship
      assert_equal 'Washington', @patient.city
      # state/county/zipcode intentionally remain unencrypted plaintext
      assert_equal 'DC', @patient.state
      assert_equal 'DC', @patient.county
      assert_equal '20001', @patient.zipcode
    end

    it 'should handle patients with nil PII fields' do
      patient = create :patient, name: 'Minimal',
                                 primary_phone: '555-999-0000',
                                 city: nil, state: nil, county: nil,
                                 other_phone: nil, other_contact: nil
      patient.reload
      assert_equal 'Minimal', patient.name
      assert_nil patient.city
      assert_nil patient.other_phone
    end

    it 'should handle empty string PII fields' do
      patient = create :patient, name: 'Empty Fields',
                                 primary_phone: '555-888-0000',
                                 city: '', other_contact: ''
      patient.reload
      assert_equal '', patient.city
      assert_equal '', patient.other_contact
    end
  end

  describe 'encrypt_sensitive_columns rake task' do
    before do
      Rails.application.load_tasks unless Rake::Task.task_defined?('patient:encrypt_sensitive_columns')
    end

    it 'should execute without error' do
      Rake::Task['patient:encrypt_sensitive_columns'].reenable
      assert_nothing_raised do
        Rake::Task['patient:encrypt_sensitive_columns'].invoke
      end
    end

    it 'should preserve data after running' do
      Rake::Task['patient:encrypt_sensitive_columns'].reenable
      Rake::Task['patient:encrypt_sensitive_columns'].invoke
      @patient.reload
      assert_equal 'Test Patient', @patient.name
      assert_equal '555-111-2222', @patient.primary_phone
    end

    it 'should process patients within tenant scope' do
      # The rake task iterates Fund.all and wraps each in with_tenant
      # Verify our patient (in current tenant) is still accessible after task
      Rake::Task['patient:encrypt_sensitive_columns'].reenable
      Rake::Task['patient:encrypt_sensitive_columns'].invoke
      # Query by deterministic field (primary_phone) since name is non-deterministic
      assert_equal 1, Patient.where(primary_phone: '555-111-2222').count
    end
  end
end
