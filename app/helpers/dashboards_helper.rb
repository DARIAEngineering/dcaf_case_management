# Convenience methods consumed in the dashboards controller index view
module DashboardsHelper
  def week_range(date: DateTime.now.in_time_zone, start_day: :monday)
    week_start = date.beginning_of_week start_day
    week_end = date.end_of_week start_day
    week_start_string = week_start.strftime('%B %-d')
    week_end_string = if week_start.month == week_end.month
                        week_end.strftime('%-d')
                      else
                        week_end.strftime('%B %-d')
                      end
    "#{week_start_string} - #{week_end_string}"
  end

  def voicemail_options
    enum_text = { not_specified: 'No instructions; no ID VM',
                  no: 'Do not leave a voicemail',
                  yes: 'Voicemail OK, ID OK' }
    vm_options = Patient::VOICEMAIL_PREFERENCE

    vm_options.map { |option| [enum_text[option], option] }
  end

  def remove_from_call_list_glyphicon
    safe_join [
      tag(:span, class: ['glyphicon', 'glyphicon-remove'], aria: { hidden: true }),
      tag(:span, class: ['sr-only'], text: 'Remove call')
    ]
  end

  def call_glyphicon
    safe_join [
      tag(:span, class: ['glyphicon', 'glyphicon-earphone'], aria: { hidden: true }),
      tag(:span, class: ['sr-only'], text: 'Call')
    ]
  end

  # column has string data
  def autosort_string_html_attr(local_assigns)
    local_assigns[:autosortable] ? ' data-sort="string"' : ''
  end

  # column has string data that should be sorted case insensitively
  def autosort_string_ins_html_attr(local_assigns)
    local_assigns[:autosortable] ? ' data-sort="string-ins"' : ''
  end

  # column has integer data
  def autosort_int_html_attr(local_assigns)
    local_assigns[:autosortable] ? ' data-sort="int"' : ''
  end

  # column has floating point data
  def autosort_float_html_attr(local_assigns)
    local_assigns[:autosortable] ? ' data-sort="float"' : ''
  end

  # span that holds the up/down arrow
  def autosort_arrow_span(local_assigns)
    local_assigns[:autosortable] ? ' <span class="arrow">[-]</span>' : '';
  end
end
