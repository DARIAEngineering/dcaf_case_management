# Controller for automatically generated service reporting across lines.
class ReportsController < ApplicationController
  def index

  end

  def weekly_report
    @weekly_report = Reports::LineSummary.generate(1.week.ago, Date.today)
    render partial: "call_line", locals: {weekly_report: @weekly_report}
  end

  def monthly_report
    @monthly_report = Reports::LineSummary.generate(1.month.ago, Date.today)
    render partial: "past_thirty_days", locals: {monthly_report: @monthly_report}
  end

  def yearly_report
    @yearly_report = Reports::LineSummary.generate(1.year.ago, Date.today)
    render partial: "year_to_date", locals: {yearly_report: @yearly_report}
  end
end
