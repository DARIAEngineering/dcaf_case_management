# Convenience methods consumed in the dashboards controller index view
module DashboardsHelper
  def week_range(date: Time.zone.now, start_day: :monday)
    week_start = date.beginning_of_week start_day
    week_end = date.end_of_week start_day
    week_start_string = l week_start, format: '%B %-d'
    week_end_string = if week_start.month == week_end.month
                        l week_end, format: '%-d'
                      else
                        l week_end, format: '%B %-d'
                      end
    "#{week_start_string} - #{week_end_string}"
  end

  def voicemail_options
    enum_text = { not_specified: t('dashboard.helpers.voicemail_options.not_specified'),
                  no: t('dashboard.helpers.voicemail_options.no'),
                  yes: t('dashboard.helpers.voicemail_options.yes') }
    Patient.voicemail_preference
           .values
           .map { |option| option.to_sym }
           .map { |option| [enum_text[option], option.to_sym] }
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
