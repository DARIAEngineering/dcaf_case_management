# Functions for cleanly displaying rows in an audit log.
module ChangeLogHelper
  # Separate changelog fields with breaks
  def safe_join_fields(shaped_changes)
    safe_join changelog_entry_display(shaped_changes), tag('br')
  end

  private

  # Map changelog entries to a html string
  def changelog_entry_display(shaped_changes)
    shaped_changes.map do |entry|
      field = content_tag('strong') { "#{entry[0]}:" }.freeze
      orig = entry[1][:original]
      separator = '->'.freeze
      mod = entry[1][:modified]

      safe_join([field, orig, separator, mod], ' ').freeze
    end
  end
end
