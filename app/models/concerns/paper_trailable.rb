# Custom PaperTrail class with a few convenience methods for pg models.
module PaperTrailable
  extend ActiveSupport::Concern

  included do
    has_paper_trail versions: { class_name: 'PaperTrailVersion',
                                scope: -> { order(id: :desc) } }
  end

  def created_by
    versions.first&.actor
  end

  def created_by_id
    created_by&.id
  end
end
