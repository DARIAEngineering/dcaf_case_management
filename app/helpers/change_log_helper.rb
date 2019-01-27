# Functions for cleanly displaying rows in an audit log.
module ChangeLogHelper
  def safe_join_fields(fields)
    safe_join fields, tag('br')
  end

  def change_or_nil(field)
    return field if field.present?
    '(empty)'
  end
end
