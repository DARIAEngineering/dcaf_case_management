# Functions to process data in the budget bar.
module BudgetBarHelper
  def progress_bar_color(type)
    color = type == :pledged ? 'warning' : 'success'
    "progress-bar-#{color}"
  end

  def progress_bar_width(value, total = 1_000)
    "width: #{to_pct(value, total)}%"
  end

  def budget_bar_expenditure_content(patient_hash)
    link = link_to patient_hash[:name], edit_patient_path(patient_hash[:id])
    appt_text = patient_hash[:appointment_date] ?
      "appt on #{patient_hash[:appointment_date]&.display_date}" :
      'no appt date'
    safe_join([link, appt_text], ' - ')
  end

  def budget_bar_remaining(expenditures, limit)
    pledged_cash = expenditures[:pledged].map { |h| h[:fund_pledge] }.inject(:+) || 0
    sent_cash = expenditures[:sent].map { |h| h[:fund_pledge] }.inject(:+) || 0
    limit - pledged_cash - sent_cash
  end

  private

  def to_pct(value, total = 1_000)
    return '0' if total == 0

    pct = (value.to_f / total.to_f) * 100
    pct.round.to_s
  end
end
