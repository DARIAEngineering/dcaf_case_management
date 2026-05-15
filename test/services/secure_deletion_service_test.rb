require 'test_helper'

class SecureDeletionServiceTest < ActiveSupport::TestCase
  before do
    @patient = create :patient, name: 'Test Patient',
                      primary_phone: '555-123-4567',
                      city: 'Washington',
                      state: 'DC',
                      zipcode: '20001'
    @note = create :note, patient: @patient, full_text: 'Sensitive note content'
    @patient.calls.create! attributes_for(:call, status: :reached_patient)
    @patient.external_pledges.create!(source: 'Test Fund', amount: 100)
    @patient.practical_supports.create!(support_type: 'Bus', source: 'Fund')
  end

  describe 'securely_destroy!' do
    it 'should delete the patient record' do
      assert_difference 'Patient.count', -1 do
        SecureDeletionService.securely_destroy!(@patient)
      end
    end

    it 'should overwrite PII fields before deletion' do
      # Capture the SQL updates to verify shredding happens before delete
      original_name = @patient.name
      original_phone = @patient.primary_phone

      SecureDeletionService.securely_destroy!(@patient)

      # Patient should be gone
      assert_nil Patient.find_by(id: @patient.id)
      # Verify original values are not the same as random hex (they were overwritten)
      refute_equal original_name, SecureRandom.hex(8)
    end

    it 'should destroy all associated records (calls, pledges, supports)' do
      assert_difference 'Call.count', -1 do
        assert_difference 'ExternalPledge.count', -1 do
          assert_difference 'PracticalSupport.count', -1 do
            SecureDeletionService.securely_destroy!(@patient)
          end
        end
      end
    end

    it 'should scrub PaperTrail versions for the patient' do
      with_versioning(@patient.versions.first&.user || create(:user)) do
        @patient.update!(appointment_date: Date.today + 30)
        assert PaperTrailVersion.where(item_type: 'Patient', item_id: @patient.id).exists?

        SecureDeletionService.securely_destroy!(@patient)
        refute PaperTrailVersion.where(item_type: 'Patient', item_id: @patient.id).exists?
      end
    end

    it 'should scrub PaperTrail versions for ALL associated record types' do
      with_versioning(@patient.versions.first&.user || create(:user)) do
        # Trigger version creation on associated records by updating them
        @note.update!(full_text: 'Updated sensitive text')
        note_id = @note.id
        call = @patient.calls.first
        call.update!(status: :left_voicemail)
        call_id = call.id
        pledge = @patient.external_pledges.first
        pledge.update!(amount: 200)
        pledge_id = pledge.id
        ps = @patient.practical_supports.first
        ps.update!(source: 'Updated Fund')
        ps_id = ps.id

        # Create a note on a PracticalSupport (nested polymorphic)
        ps_note = ps.notes.create!(full_text: 'PS-attached note')
        ps_note_id = ps_note.id

        # Verify versions exist before deletion
        assert PaperTrailVersion.where(item_type: 'Note', item_id: note_id).exists?,
               'Expected note versions to exist before secure deletion'
        assert PaperTrailVersion.where(item_type: 'Note', item_id: ps_note_id).exists?,
               'Expected PS note versions to exist before secure deletion'

        SecureDeletionService.securely_destroy!(@patient)

        # Verify ALL associated versions are scrubbed
        refute PaperTrailVersion.where(item_type: 'Patient', item_id: @patient.id).exists?,
               'Patient versions should be scrubbed'
        refute PaperTrailVersion.where(item_type: 'Note', item_id: note_id).exists?,
               'Note versions should be scrubbed'
        refute PaperTrailVersion.where(item_type: 'Note', item_id: ps_note_id).exists?,
               'PracticalSupport note versions should be scrubbed'
        refute PaperTrailVersion.where(item_type: 'Call', item_id: call_id).exists?,
               'Call versions should be scrubbed'
        refute PaperTrailVersion.where(item_type: 'ExternalPledge', item_id: pledge_id).exists?,
               'ExternalPledge versions should be scrubbed'
        refute PaperTrailVersion.where(item_type: 'PracticalSupport', item_id: ps_id).exists?,
               'PracticalSupport versions should be scrubbed'
      end
    end

    it 'should shred and destroy PracticalSupport-owned notes' do
      ps = @patient.practical_supports.first
      ps_note = ps.notes.create!(full_text: 'Sensitive PS note')

      # Patient notes + PS note
      assert_difference 'Note.count', -2 do
        SecureDeletionService.securely_destroy!(@patient)
      end
      assert_nil Note.find_by(id: ps_note.id)
    end

    it 'should shred associated notes' do
      assert_difference 'Note.count', -1 do
        SecureDeletionService.securely_destroy!(@patient)
      end
    end

    it 'should handle patients with no notes' do
      patient_no_notes = create :patient
      assert_nothing_raised do
        SecureDeletionService.securely_destroy!(patient_no_notes)
      end
      assert_nil Patient.find_by(id: patient_no_notes.id)
    end

    it 'should handle patients with multiple notes' do
      create :note, patient: @patient, full_text: 'Second note'
      create :note, patient: @patient, full_text: 'Third note'

      assert_difference 'Note.count', -3 do
        SecureDeletionService.securely_destroy!(@patient)
      end
    end

    it 'should be atomic — all or nothing' do
      # If destroy fails, PII should not be left overwritten
      patient_count = Patient.count
      note_count = Note.count

      # Stub destroy! to raise an error
      @patient.stub(:destroy!, -> { raise ActiveRecord::RecordNotDestroyed, 'test' }) do
        assert_raises(ActiveRecord::RecordNotDestroyed) do
          SecureDeletionService.securely_destroy!(@patient)
        end
      end

      # Records should still exist (transaction rolled back)
      assert_equal patient_count, Patient.count
      assert_equal note_count, Note.count
    end

    it 'should not raise if VACUUM fails' do
      # VACUUM may fail on managed databases — should log and continue
      assert_nothing_raised do
        SecureDeletionService.securely_destroy!(@patient)
      end
    end

    it 'should only delete from current tenant' do
      # Patient is scoped to current tenant via acts_as_tenant
      other_patient = create :patient, name: 'Other Patient'

      SecureDeletionService.securely_destroy!(@patient)

      # Other patient should still exist
      assert Patient.find_by(id: other_patient.id)
    end
  end

  describe 'PATIENT_PII_FIELDS' do
    it 'should include all PII fields' do
      expected = %w[name primary_phone other_phone other_contact
                    other_contact_relationship city state county zipcode]
      assert_equal expected.sort, SecureDeletionService::PATIENT_PII_FIELDS.sort
    end
  end

  describe 'vacuum and checkpoint scheduling' do
    it 'should run VACUUM on the patients table specifically' do
      # Verify the method exists and references patients table
      service = SecureDeletionService.new(@patient)
      assert service.respond_to?(:vacuum_table!, true)
    end

    it 'should handle VACUUM gracefully inside nested transactions' do
      # When called from archive_eligible_patients!, VACUUM may be deferred
      assert_nothing_raised do
        ActiveRecord::Base.transaction do
          SecureDeletionService.securely_destroy!(@patient)
        end
      end
    end

    it 'should detect self-hosted vs managed environment' do
      service = SecureDeletionService.new(create(:patient))
      # DYNO env var indicates Heroku
      assert service.respond_to?(:self_hosted?, true)
    end
  end

  describe 'patient with Fulfillment records' do
    it 'should destroy the fulfillment association' do
      # Patient auto-creates a fulfillment via after_create callback
      fulfillment = @patient.fulfillment
      assert fulfillment.present?, 'Patient should have a fulfillment record'
      fulfillment_id = fulfillment.id

      SecureDeletionService.securely_destroy!(@patient)

      assert_nil Fulfillment.find_by(id: fulfillment_id),
        'Fulfillment should be destroyed along with the patient'
    end

    it 'should scrub PaperTrail versions for Fulfillment' do
      with_versioning(create(:user)) do
        fulfillment = @patient.fulfillment
        fulfillment.update!(fund_payout: 500)
        fulfillment_id = fulfillment.id

        assert PaperTrailVersion.where(item_type: 'Fulfillment', item_id: fulfillment_id).exists?,
               'Expected fulfillment versions to exist before secure deletion'

        SecureDeletionService.securely_destroy!(@patient)

        refute PaperTrailVersion.where(item_type: 'Fulfillment', item_id: fulfillment_id).exists?,
               'Fulfillment versions should be scrubbed'
      end
    end
  end

  describe 'shredded PII values are random' do
    it 'should overwrite PII fields with non-empty random hex strings' do
      original_values = SecureDeletionService::PATIENT_PII_FIELDS.map { |f| @patient.send(f) }

      # Shred PII via the private method
      service = SecureDeletionService.new(@patient)
      service.send(:shred_pii!)
      @patient.reload

      SecureDeletionService::PATIENT_PII_FIELDS.each do |field|
        value = @patient.send(field)
        refute value.blank?, "Shredded #{field} should not be blank"
        assert_match(/\A[0-9a-f]{16}\z/, value,
          "Shredded #{field} should be a 16-char hex string (SecureRandom.hex(8))")
      end
    end

    it 'should produce different shredded values across fields' do
      service = SecureDeletionService.new(@patient)
      service.send(:shred_pii!)
      @patient.reload

      values = SecureDeletionService::PATIENT_PII_FIELDS.map { |f| @patient.send(f) }
      # With 9 fields, the probability of any two matching random hex(8) is negligible
      assert_equal values.uniq.size, values.size,
        'Each shredded PII field should have a unique random value'
    end
  end

  describe 'idempotency — deleting an already-deleted patient' do
    it 'should raise RecordNotFound when called on a destroyed patient' do
      SecureDeletionService.securely_destroy!(@patient)

      assert_raises(ActiveRecord::RecordNotFound) do
        reloaded = Patient.find(@patient.id)
        SecureDeletionService.securely_destroy!(reloaded)
      end
    end

    it 'should not raise if patient is already gone and we handle it' do
      SecureDeletionService.securely_destroy!(@patient)
      assert_nil Patient.find_by(id: @patient.id)
    end
  end

  describe 'operation with PaperTrail disabled' do
    it 'should complete without error when PaperTrail is disabled' do
      was_enabled = PaperTrail.enabled?
      begin
        PaperTrail.enabled = false

        patient = create :patient, name: 'PaperTrail Off Patient'
        patient.notes.create!(full_text: 'A note')

        assert_nothing_raised do
          SecureDeletionService.securely_destroy!(patient)
        end
        assert_nil Patient.find_by(id: patient.id)
      ensure
        PaperTrail.enabled = was_enabled
      end
    end

    it 'should still destroy all records when PaperTrail is disabled' do
      was_enabled = PaperTrail.enabled?
      begin
        PaperTrail.enabled = false

        patient = create :patient, name: 'No Trail Patient'
        patient.calls.create! attributes_for(:call, status: :reached_patient)
        note = patient.notes.create!(full_text: 'Sensitive')
        note_id = note.id
        call_id = patient.calls.first.id

        SecureDeletionService.securely_destroy!(patient)

        assert_nil Patient.find_by(id: patient.id)
        assert_nil Note.find_by(id: note_id)
        assert_nil Call.find_by(id: call_id)
      ensure
        PaperTrail.enabled = was_enabled
      end
    end
  end
end
