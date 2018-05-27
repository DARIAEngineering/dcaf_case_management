# Functions to process data in the budget bar.
module BudgetBarHelper
  def progress_bar_color(type)
    color = type == :pledged ? 'warning' : 'success'
    "progress-bar-#{color}"
  end

  def progress_bar_width(value, total = nil)
    "width: #{to_pct(value, total)}%"
  end

  def budget_bar_expenditure_content(patient_hash)
    link_to patient_hash[:identifier], edit_patient_path(patient_hash[:id])
  end

  def budget_bar_remaining(expenditures, limit)
    pledged_cash = expenditures[:pledged].map { |h| h[:fund_pledge] }.inject(:+) || 0
    sent_cash = expenditures[:sent].map { |h| h[:fund_pledge] }.inject(:+) || 0
    limit - pledged_cash - sent_cash
  end

  private

  def to_pct(value, total)
    pct = (value.to_f / total.to_f) * 100
    pct.round.to_s
  end
end
