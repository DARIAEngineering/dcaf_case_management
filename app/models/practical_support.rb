# Representation of non-monetary assistance coordinated for a patient.
class PracticalSupport < ApplicationRecord
  # Ignore legacy boolean columns replaced by :status enum. Safe to remove
  # once 20250101000007_remove_old_boolean_columns migration has run.
  self.ignored_columns += %w[confirmed fulfilled]

  acts_as_tenant :fund

  encrypts :attachment_url

  # Concerns
  include PaperTrailable
  include Notetakeable

  # Relationships
  belongs_to :can_support, polymorphic: true, touch: true
  has_many :notes, as: :can_note

  # Status workflow: requested → in_progress → approved → completed
  # cancelled can be set from any state
  # Note: "approved" replaces old "confirmed" to avoid collision with the
  # legacy boolean `confirmed` column (removed in migration).
  enum :status, {
    requested: 0,
    in_progress: 1,
    approved: 2,
    completed: 3,
    cancelled: 4
  }

  STATUS_BADGE_COLORS = {
    'requested' => 'badge-secondary',
    'in_progress' => 'badge-info',
    'approved' => 'badge-primary',
    'completed' => 'badge-success',
    'cancelled' => 'badge-danger'
  }.freeze

  # Scopes
  scope :overdue, -> {
    where(status: [:requested, :in_progress])
      .where('COALESCE(status_updated_at, created_at) < ?', 7.days.ago)
  }

  scope :active, -> { where.not(status: [:completed, :cancelled]) }

  # Validations
  validates :source, :support_type, presence: true, length: { maximum: 150 }
  validates :amount,
            allow_nil: true,
            numericality: { greater_than_or_equal_to: 0 }

  # Callbacks
  before_save :track_status_change, if: :status_changed?
  after_initialize :set_initial_status_timestamp, if: :new_record?

  def badge_color
    STATUS_BADGE_COLORS[status] || 'badge-secondary'
  end

  private

  def track_status_change
    self.status_updated_at = Time.current
  end

  def set_initial_status_timestamp
    self.status_updated_at ||= Time.current
  end
end
