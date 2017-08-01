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
    vm_options = Patient.voicemail_preference.values
    vm_options.map! { |option| option.to_sym }

    vm_options.map { |option| [enum_text[option], option.to_sym] }
  end

  def remove_from_call_list_glyphicon
    safe_join [
      tag(:span, class: ['glyphicon', 'glyphicon-remove'],
                 aria: { hidden: true }),
      tag(:span, class: ['sr-only'], text: 'Remove call')
    ]
  end

  def call_glyphicon
    safe_join [
      tag(:span, class: ['glyphicon', 'glyphicon-earphone'],
                 aria: { hidden: true }),
      tag(:span, class: ['sr-only'], text: 'Call')
    ]
  end
end
