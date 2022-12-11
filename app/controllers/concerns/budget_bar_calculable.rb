module BudgetBarCalculable
  extend ActiveSupport::Concern
  include BudgetBarHelper

  def budget_bar_calculations(line)
    expenditures = Patient.pledged_status_summary line
    default_cash_ceiling = Config.budget_bar_max

    cash_spent = sum_fund_pledges expenditures.values.flatten
    { limit: [default_cash_ceiling, cash_spent].max,
      expenditures: expenditures }
  end
end
