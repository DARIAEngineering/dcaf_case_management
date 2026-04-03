# Custom PaperTrail class with a few convenience methods for pg models.
module PaperTrailable
  extend ActiveSupport::Concern

  included do
    pt_opts = { versions: { class_name: 'PaperTrailVersion',
                            scope: -> { order(id: :desc) } } }
    pt_opts[:ignore] = self::PAPER_TRAIL_IGNORE if const_defined?(:PAPER_TRAIL_IGNORE, false)
    has_paper_trail(**pt_opts)
  end

  def created_by
    versions.last&.user
  end

  def created_by_id
    created_by&.id
  end

  def updated_by
    versions.first&.user
  end

  def updated_by_id
    updated_by&.id
  end
end
