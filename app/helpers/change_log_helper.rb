module ChangeLogHelper
  def safe_join_fields(fields)
    fields.join tag('br')
  end
end
