# Object representing a patient's call list.
class CallListEntry
  include Mongoid::Document
  include Mongoid::Timestamps

  # Relationships
  belongs_to :user
  belongs_to :patient

  # Fields
  field :order_key, type: Integer
  field :line, type: String

  # Validations
  validates :order_key, :line, presence: true
  validates :patient, uniqueness: { scope: :user }

  # Indices
  index line: 1

  def self.destroy_orphaned_entries
    includes(:patient).reject(&:patient)
                      .each { |x| x.destroy }
  end
end
