module BudgetBarCalculable
  extend ActiveSupport::Concern

  def budget_bar_calculations(line)
    expenditures = Patient.pledged_status_summary line
    default_cash_ceiling = 1_000

    cash_spent = expenditures.values.flatten.map { |x| x[:fund_pledge] }.inject(:+) || 0
    { limit: [default_cash_ceiling, cash_spent].max,
      expenditures: expenditures }
  end
end
