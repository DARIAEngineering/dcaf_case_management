module ApplicationHelper
  # helper method to display form validation errors
  # see /users/new for examples
  def error_message(obj, field)
    return if obj.errors[field].empty?
    str = ''
    obj.errors[field].each do |error|
      str += "<span class='form-error'>#{field.to_s.humanize} #{error}</span><br/>"
    end
    str.html_safe
  end
end
