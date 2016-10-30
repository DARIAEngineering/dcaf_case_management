module ChangeLogHelper
  def safe_join_fields(fields)
    safe_join fields, tag('br')
  end
end
