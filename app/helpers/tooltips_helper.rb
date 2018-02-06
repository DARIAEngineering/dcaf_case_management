# Populate bootstrap tooltip text
module TooltipsHelper
  def tooltip_shell(help_text)
    content_tag :span, class: 'daria-tooltip tooltip-header-help',
                       title: help_text,
                       data: { toggle: 'tooltip', placement: 'top' } do
      '(?)'
    end
  end

  def your_call_list_help_text
    text = <<-TEXT
      This sortable list is used to keep track of patients to call back
      during your shift. Use the search to populate it.
    TEXT
    text.strip
  end

  def your_completed_calls_help_text
    text = <<-TEXT
      This is a list of patients you have already called tonight.
    TEXT
    text.strip
  end

  def urgent_cases_help_text
    text = <<-TEXT
      These are patients who require a little more attention. This list is
      shared across all case managers working on a single line. Patients are
      removed from this list automatically after they are marked as having
      a sent pledge, or marked as resolved without assistance.
    TEXT
    text.strip
  end

  def status_help_text
    text = <<-TEXT
      true
    TEXT
    text.strip
  end

  def record_new_external_pledge_help_text
    text = <<-TEXT
      To record a pledge from another abortion fund, choose the fund from the
      dropdown menu, enter the amount of the pledge, and click Create
      External Pledge.
    TEXT
    text.strip
  end

  def resolved_without_fund_help_text
    text = <<-TEXT
      This status indicates a patient does not require our services any longer.
    TEXT
    text.strip
  end
end
