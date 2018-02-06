# Populate bootstrap tooltip text
module TooltipsHelper
  def tooltip_shell(help_text)
    content_tag :span, class: 'daria-tooltip tooltip-header-help',
                       title: help_text,
                       data: { toggle: 'tooltip', placement: 'bottom' } do
      '(?)'
    end
  end

  def your_call_list_help_text
    'This sortable list is used to keep track of patients to call back during your shift. Use the search to populate it.'
  end

  def your_completed_calls_help_text
    'This is a list of patients you have already called tonight.'
  end

  def urgent_cases_help_text
    'These are patients who require a little more attention. This list is shared across all case managers working on a single line.'
  end

  def status_help_text
    true
  end

  def record_new_external_pledge_help_text
    'To record a pledge from another abortion fund, choose the fund from the dropdown menu, enter the amount of the pledge, and click Create External Pledge.'
  end

  def resolved_without_dcaf_help_text
    'This status indicates a patient does not require our services any longer.'
  end
end
