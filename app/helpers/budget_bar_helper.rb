# Functions to process data in the budget bar.
module BudgetBarHelper
  def progress_bar_color(type)
    color = type == :pledged ? 'warning' : 'success'
    "bg-#{color}"
  end

  def progress_bar_width(value, cash_ceiling = Config.budget_bar_max)
    "width: #{to_pct(value, cash_ceiling)}%"
  end

  def budget_bar_expenditure_content(patient_hash)
    link = link_to patient_hash[:name], edit_patient_path(patient_hash[:id])
    appt_text = if patient_hash[:appointment_date]
                  t 'dashboard.budget_bar.pop_content_appt_date', date: patient_hash[:appointment_date]&.display_date
                else
                  t 'dashboard.budget_bar.pop_content_no_appt_date'
                end
    safe_join([link, appt_text], ' - ')
  end

  def sum_fund_pledges(pledges)
    total = pledges.map{ |h| h[:fund_pledge] }.sum
    total
  end

  def budget_bar_remaining(expenditures, limit)
    pledged_cash = sum_fund_pledges expenditures[:pledged]
    sent_cash = sum_fund_pledges expenditures[:sent]
    limit - pledged_cash - sent_cash
  end

  # we can call the builder directly for `remaining` but use the main function,
  # below, otherwise.
  def budget_bar_statistic_builder(name:, amount:, count: nil, limit:, show_aggregate_statistics: true)
    formatted_amount = number_to_currency(amount,
                                          precision: 0,
                                          unit: '$',
                                          format: '%u%n')

    # if count is nil, don't mention the patients                               
    if count.present?
      patient_string = pluralize(count, t('common.patient').downcase)
    end

    if show_aggregate_statistics
      # if displaying both, need a comma!
      if patient_string.present?
        patient_string += ", "
      end

      percent_string = "#{to_pct(amount)}%"
    end

    # looks like: "$10 spent (4 patients, 10%)"
    statistic = "#{formatted_amount} #{name} (#{patient_string}#{percent_string})"
    statistic
  end

  def budget_bar_statistic(name, expenditures, limit:, show_aggregate_statistics: true)
    budget_bar_statistic_builder name: name,
                                 amount: sum_fund_pledges(expenditures),
                                 count: expenditures.count,
                                 limit: limit,
                                 show_aggregate_statistics: show_aggregate_statistics
  end


  private

  def to_pct(value, cash_ceiling = Config.budget_bar_max)
    return '0' if cash_ceiling == 0

    pct = (value.to_f / cash_ceiling.to_f) * 100
    pct.round.to_s
  end

end
