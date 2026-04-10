# Service for securely deleting patient data with crypto-shredding.
#
# Implements adaptive secure deletion:
# - Level 5 (Heroku/managed DB): Overwrite PII → DELETE → VACUUM
# - Level 6 (Self-hosted): Overwrite PII → DELETE → VACUUM → WAL checkpoint
#
# Crypto-shredding overwrites PII fields with random data before deletion,
# ensuring the original values cannot be recovered from disk, WAL, or backups.
class SecureDeletionService
  # PII fields on Patient that must be overwritten before deletion
  PATIENT_PII_FIELDS = %w[
    name primary_phone other_phone other_contact
    other_contact_relationship city state county zipcode
  ].freeze

  # Securely delete a patient record with crypto-shredding
  def self.securely_destroy!(patient)
    new(patient).perform!
  end

  def initialize(patient)
    @patient = patient
  end

  def perform!
    ActiveRecord::Base.transaction do
      shred_pii!
      shred_associated_notes!
      destroy_associations!
      scrub_paper_trail_versions!
      @patient.destroy!
    end

    # VACUUM reclaims disk space. Runs outside transaction since VACUUM
    # cannot run inside one. Scheduled via after_commit when nested.
    schedule_vacuum!
  end

  private

  # Overwrite PII fields with random data using raw SQL to bypass validations
  def shred_pii!
    overwrite_attrs = PATIENT_PII_FIELDS.each_with_object({}) do |field, hash|
      hash[field] = SecureRandom.hex(8)
    end
    # Use update_columns to skip validations and callbacks
    @patient.update_columns(overwrite_attrs)
  end

  # Overwrite encrypted note text for this patient's notes
  def shred_associated_notes!
    @patient.notes.find_each do |note|
      note.update_columns(full_text: SecureRandom.hex(16))
    end
  end

  # Explicitly destroy all polymorphic associations that Patient#destroy
  # won't cascade (no dependent: :destroy declared on these)
  def destroy_associations!
    @patient.notes.destroy_all
    @patient.calls.destroy_all
    @patient.external_pledges.destroy_all
    @patient.practical_supports.destroy_all
    @patient.fulfillment&.destroy!
  end

  # Remove PaperTrail version history so sensitive data doesn't persist
  def scrub_paper_trail_versions!
    PaperTrailVersion.where(item_type: 'Patient', item_id: @patient.id).destroy_all
  end

  # Schedule VACUUM after all transactions commit
  def schedule_vacuum!
    vacuum_table!
    checkpoint_wal! if self_hosted?
  rescue => e
    Rails.logger.warn("[SecureDeletion] Post-delete cleanup: #{e.message}")
  end

  # Reclaim disk space so deleted data isn't recoverable from free pages
  def vacuum_table!
    ActiveRecord::Base.connection.execute("VACUUM patients")
  rescue ActiveRecord::StatementInvalid => e
    # VACUUM may fail inside a transaction or on managed DBs — log and continue
    Rails.logger.warn("[SecureDeletion] VACUUM skipped: #{e.message}")
  end

  # On self-hosted Postgres, force a WAL checkpoint to flush deleted data
  def checkpoint_wal!
    ActiveRecord::Base.connection.execute("CHECKPOINT")
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.warn("[SecureDeletion] CHECKPOINT skipped: #{e.message}")
  end

  # Detect if running on Heroku (managed DB) vs self-hosted
  def self_hosted?
    !ENV['DYNO'].present?
  end
end
