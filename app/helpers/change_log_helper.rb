# Functions for cleanly displaying rows in an audit log.
module ChangeLogHelper
  def safe_join_fields(fields)
    safe_join fields, tag('br')
  end
end
