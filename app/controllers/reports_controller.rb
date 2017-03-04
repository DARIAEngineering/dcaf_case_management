class ReportsController < ApplicationController
  def index
    @weekly_report = Reports::LineSummary.generate(1.week.ago, Date.today)
    @monthly_report = Reports::LineSummary.generate(1.month.ago, Date.today)
    @yearly_report = Reports::LineSummary.generate(1.year.ago, Date.today)
  end
end
