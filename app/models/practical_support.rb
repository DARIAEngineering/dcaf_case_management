# Representation of non-monetary assistance coordinated for a patient.
class PracticalSupport < ApplicationRecord
  acts_as_tenant :fund

  encrypts :attachment_url

  # Concerns
  include PaperTrailable
  include Notetakeable

  # Relationships
  belongs_to :can_support, polymorphic: true
  has_many :notes, as: :can_note

  # Status workflow: requested → in_progress → confirmed → completed
  # cancelled can be set from any state
  enum :status, {
    requested: 0,
    in_progress: 1,
    confirmed: 2,
    completed: 3,
    cancelled: 4
  }

  STATUS_BADGE_COLORS = {
    'requested' => 'badge-secondary',
    'in_progress' => 'badge-info',
    'confirmed' => 'badge-primary',
    'completed' => 'badge-success',
    'cancelled' => 'badge-danger'
  }.freeze

  # Scopes
  scope :overdue, -> {
    where(status: [:requested, :in_progress])
      .where('created_at < ?', 7.days.ago)
  }

  scope :active, -> { where.not(status: [:completed, :cancelled]) }

  # Validations
  validates :source, :support_type, presence: true, length: { maximum: 150 }
  validates :amount,
            allow_nil: true,
            numericality: { greater_than_or_equal_to: 0 }

  # Callbacks
  before_save :track_status_change, if: :status_changed?

  def badge_color
    STATUS_BADGE_COLORS[status] || 'badge-secondary'
  end

  private

  def track_status_change
    self.status_updated_at = Time.current
    self.confirmed_at = Time.current if confirmed?
  end
end
