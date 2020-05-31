# Populate bootstrap tooltip text
module TooltipsHelper
  def tooltip_shell(help_text)
    content_tag :span, class: 'daria-tooltip tooltip-header-help',
                       data: { toggle: 'tooltip',
                               html: true,
                               placement: 'bottom',
                               title: help_text } do
      '(?)'
    end
  end

  def dashboard_table_content_tooltip_shell(table_type)
    return if table_type == 'search_results'

    method_name = "#{table_type}_help_text"
    help_text = public_send(method_name)
    tooltip_shell help_text
  end

  def call_list_help_text
    t('tooltips.call_list').strip
  end

  def budget_bar_help_text
    t('tooltips.budget_bar', fund: FUND).strip
  end

  def completed_calls_help_text
    t('tooltips.completed_calls').strip
  end

  def urgent_cases_help_text
    t('tooltips.urgent_cases').strip
  end

  def status_help_text(patient)
    status = Statusable::STATUSES.find { |x, hsh| hsh[:key] == patient.status }
                                 .second

    status_def = "#{status[:key]}: #{status[:help_text]}"

    safe_join(["#{t('tooltips.status_definition')}:"].concat([status_def]), tag('br'))
  end

  def record_new_external_pledge_help_text
    t('tooltips.record_new_external_pledge').strip
  end

  def resolved_without_fund_help_text
    t('tooltips.resolved_without_fund').strip
  end

  def referred_to_clinic_help_text
    t('tooltips.referred_to_clinic').strip
  end

  def mandatory_ultrasound_help_text
    t('tooltips.mandatory_ultrasound').strip
  end
end
