# Functions to process data in the budget bar.
module BudgetBarHelper
  def progress_bar_color(type)
    color = type == :pledged ? 'warning' : 'success'
    "progress-bar-#{color}"
  end

  def progress_bar_width(value, total = nil)
    "width: #{to_pct(value, total)}%"
  end

  private

  def to_pct(value, total)
    budget_total = total || 1_350
    pct = (value.to_f / budget_total.to_f) * 100
    pct.round.to_s
  end
end
