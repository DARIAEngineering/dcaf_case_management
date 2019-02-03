# Populate bootstrap tooltip text
module TooltipsHelper
  def tooltip_shell(help_text)
    content_tag :span, class: 'daria-tooltip tooltip-header-help',
                       title: help_text,
                       data: { toggle: 'tooltip' } do
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
    text = <<-TEXT
      This sortable list is used to keep track of patients to call back
      during your shift. Use the search to populate it.
    TEXT
    text.strip
  end

  def budget_bar_help_text
    text = <<-TEXT
      The budget bar lists money tentatively set aside for a patient
      (by entering a value in the #{FUND} pledge field) and money sent to a clinic for a patient (by checking the I sent the pledge checkbox) over a given week. It resets on Mondays.
    TEXT
    text.strip
  end

  def completed_calls_help_text
    text = <<-TEXT
      This is a list of patients you have called within the last 8 hours.
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

  def status_help_text(patient)
    status = Statusable::STATUSES.find { |x, hsh| hsh[:key] == patient.status }
                                 .second

    status_def = "#{status[:key]}: #{status[:help_text]}"

    safe_join(['Status definition:'].concat([status_def]), tag('br'))
  end

  def record_new_external_pledge_help_text
    text = <<-TEXT
      External pledges is our term for pledges by other abortion funds also
      working with a patient.
    TEXT
    text.strip
  end

  def resolved_without_fund_help_text
    text = <<-TEXT
      This is used to indicate that a patient does not require or want
      our services any longer.
    TEXT
    text.strip
  end

  def referred_to_clinic_help_text
    text = <<-TEXT
      Check this box if you as a case manager referred the patient to a
      particular clinic.
    TEXT
    text.strip
  end

  def mandatory_ultrasound_help_text
    'If you are in a state that requires ultrasounds and the patient has completed one, you can log it here.'
  end
end
