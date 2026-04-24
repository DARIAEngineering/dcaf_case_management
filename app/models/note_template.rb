# Note templates allow funds and individual users to save reusable note text.
# Fund-level templates (user_id nil) are available to all users in the fund.
# Personal templates (user_id set) are only visible to that user.
class NoteTemplate < ApplicationRecord
  acts_as_tenant :fund

  belongs_to :user, optional: true

  validates :name, presence: true, uniqueness: { scope: [:fund_id, :user_id] }
  validates :full_text, presence: true

  scope :fund_level, -> { where(user_id: nil) }
  scope :personal, ->(user) { where(user: user) }
  scope :available_to, ->(user) {
    where(user_id: [nil, user.id]).order(:name)
  }
end
