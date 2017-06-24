# Controller for automatically generated service reporting across lines.
class ReportsController < ApplicationController
  def index
    # @weekly_report = gon.weekly_report = Reports::LineSummary.generate(1.week.ago, Date.today)
    # @monthly_report = gon.monthly_report = Reports::LineSummary.generate(1.month.ago, Date.today)
    # @yearly_report = gon.yearly_report = Reports::LineSummary.generate(1.year.ago, Date.today)
  end

  def weekly_report
    puts 'going async'
    @weekly_report = gon.weekly_report = Reports::LineSummary.generate(1.week.ago, Date.today)
    render partial: "call_line", locals: {weekly_report: @weekly_report}
  end

  def monthly_report
    puts 'going async'
    @monthly_report = gon.monthly_report = Reports::LineSummary.generate(1.month.ago, Date.today)
    render partial: "past_thirty_days"
  end

  def yearly_report
    @yearly_report = gon.yearly_report = Reports::LineSummary.generate(1.year.ago, Date.today)
    render partial: "year_to_date"
  end
end
