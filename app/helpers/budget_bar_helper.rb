module BudgetBarHelper
  def progress_bar_color(type)
    color = type == :pledged ? 'warning' : 'success'
    "progress-bar-#{color}"
  end

  def progress_bar_width(value)
    "width: #{to_pct(value)}%"
  end

  private

  def to_pct(value)
    pct = (value.to_f / 1_350.to_f) * 100
    pct.round.to_s
  end
end
