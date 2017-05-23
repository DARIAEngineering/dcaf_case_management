module UsersHelper
  def user_role_options
    [
      ['Case manager', 'cm'],
      ['Data volunteer', 'data_volunteer'],
      ['Admin', 'admin']
    ]
  end

  def th_autosortable(column_name, type, local_assigns)
    # Throw a flag unless sorting by string, int, or float
    raise 'Bad datatype' unless %w(string string-ins int float).include? type
    content_tag :th, data: { sort: type } do
      safe_join [column_name, autosort_arrow_span(local_assigns)], ' '
    end
  end

  def autosort_arrow_span(local_assigns)
    puts 'putting local_assigns'
    puts local_assigns
    return '' unless local_assigns[:autosortable]
    content_tag(:span, '[-]', class: 'arrow')
  end
end
